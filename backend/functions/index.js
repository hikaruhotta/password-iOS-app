const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const validation = require('./validation');
const utils = require('./utils');
const lobbyUtils = require('./lobby-utils');
const wordUtils = require('./word-utils');

/**
 * Performs a transaction on a lobby object.
 * If validateLobbyFn returns an error, aborts the transaction and throws the returned error.
 * Otherwise updates the lobby object by calling updateLobbyFn.
 * @param {string} lobbyId id of lobby to update
 * @param {function} validateLobbyFn (lobby) => { return Error || null; }
 * @param {function} updateLobbyFn (lobby) => { modifyLobbyInPlace; return; }
 */
async function updateLobby(lobbyId, validateLobbyFn, updateLobbyFn) {
    const lobbyRef = admin.database().ref('/lobbies/' + lobbyId);
    let transactionError;
    return lobbyRef.transaction(lobby => {
        /* When the path /lobbies/lobbyId doesn't exist, the value of `lobby` passed into the transaction
         * callback will be null. However, we shouldn't abort the transaction when that happens, as
         * that can happen in some other transaction-edge-case scenarios. But in those situations,
         * the transaction won't complete, while when the path doesn't exist, it will.
         * So, return null in the transaction if lobby is null, then if the transaction completes and 
         * the snapshot is still null, we know that lobbyId is missing and can throw our error here. */
        if (lobby === null) {
            transactionError = new functions.https.HttpsError("not-found",
                `Lobby with id ${lobbyId} not found.`);
            return null;
        }
        transactionError = validateLobbyFn(lobby);
        if (transactionError) {
            return undefined; // abort transaction
        }
        updateLobbyFn(lobby);
        return lobby;
    }).then(result => {
        if (!result.committed || !result.snapshot.exists()) {
            throw transactionError;
        }
        return result.snapshot.val();
    });
}

/**
 * Try to add a player to the lobby with id `lobbyId`.
 * Returns promise that resolves on addition or rejects with error if lobby missing or closed.
 * Assumes player object is valid.
 */
async function addPlayerToLobby(lobbyId, player, playerId) {
    const validateLobbyFn = lobby => {
        if (lobby.public.status !== 'LOBBY') {
            return new functions.https.HttpsError("failed-precondition",
                `Lobby with id ${lobbyId} is no longer open to join.`);
        }
        return null;
    };

    const updateLobbyFn = lobby => {
        if (!lobby.public.players) {
            lobby.public.players = {};
        }
        player.score = 0;
        lobby.public.players[playerId] = player;
    };
    
    const lobbyUpdate = updateLobby(lobbyId, validateLobbyFn, updateLobbyFn);
    const playerMapping = admin.database().ref('/playerLobbyMap/' + playerId).set(lobbyId);
    return Promise.all([lobbyUpdate, playerMapping]);
}

exports.createLobby = functions.https.onCall(async (data, context) => {
    const now = admin.database.ServerValue.TIMESTAMP;
    const playerId = validation.getUid(context);
    const player = validation.getPlayer(data);
    
    const lobbyCreation = admin.database().ref('/lobbies/').push({
        internal: {
            created: now,
            hostId: playerId
        },
        public: {
            status: "LOBBY",
        }
    });
    // lobbyCreation is a "ThenableReference";
    // a promise whose .key property can be accessed immediately
    const lobbyId = lobbyCreation.key;
    const lobbyCodeCreation = lobbyUtils.createLobbyCodeMapping(lobbyId, now);
    const hostAdding = lobbyCreation.then(() => {
        return addPlayerToLobby(lobbyId, player, playerId);
    });

    const lobbyCode = await lobbyCodeCreation;
    await hostAdding;
    return { lobbyId: lobbyId, lobbyCode: lobbyCode };
});

exports.joinLobby = functions.https.onCall(async (data, context) => {
    const playerId = validation.getUid(context);
    const player = validation.getPlayer(data);
    const lobbyCode = validation.getLobbyCode(data);
    const lobbyId = await lobbyUtils.findLobbyIdFromCode(lobbyCode);

    await addPlayerToLobby(lobbyId, player, playerId);
    return { lobbyId: lobbyId };
});

function startNextTurnOrEndGame(lobby) {
    const numTurnsTaken = lobby.public.turns.length;
    const numPlayers = lobby.public.playerOrder.length;
    const numRounds = lobby.public.settings.numRounds;

    const gameIsFinished = (numTurnsTaken === numRounds * numPlayers);
    if (gameIsFinished) {
        lobby.public.status = "DONE";
    } else {
        // start next turn
        const nextPlayer = lobby.public.playerOrder[numTurnsTaken % numPlayers];
        const now = admin.database.ServerValue.TIMESTAMP;
        lobby.public.turns.push({ player: nextPlayer, created: now });
        lobby.public.status = "SUBMISSION";
    }
}

function scoreTurn(lobby) {
    const numTurnsSoFar = lobby.public.turns.length;
    const doneTurn = lobby.public.turns[numTurnsSoFar - 1];
    const player = lobby.public.players[doneTurn.player];

    if (doneTurn.wasOthersWord) {
        const other = lobby.public.players[doneTurn.otherId];
        other.score += 2;
        return;
    }

    let wasChallenged = false;
    for (const uid in doneTurn.votes) {
        const votedChallenge = doneTurn.votes[uid];
        if (votedChallenge) {
            wasChallenged = true;
            const challenger = lobby.public.players[uid];
            if (doneTurn.wasSubmittersWord) {
                challenger.score += 2;
                player.score -= 1;
            } else {
                challenger.score -= 1;
                player.score -= 1;
            }
        }
    }

    if (!wasChallenged) {
        if (doneTurn.wasSubmittersWord) {
            player.score += 2;
        } else {
            // nothing happens
        }
    }
}

exports.startGame = functions.https.onCall(async (data, context) => {
    const playerId = validation.getUid(context);
    const gameSettings = validation.getGameSettings(data);
    const lobbyId = await lobbyUtils.findLobbyIdFromUID(playerId);

    const validateLobbyFn = lobby => {
        if (lobby.internal.hostId !== playerId) {
            return new functions.https.HttpsError("permission-denied",
                `You are not the host of the lobby with id ${lobbyId}.`);
        }
        if (lobby.public.status !== 'LOBBY') {
            return new functions.https.HttpsError("failed-precondition",
                `Lobby with id ${lobbyId} already started.`);
        }
        return null;
    };
    
    const updateLobbyFn = lobby => {
        lobby.public.settings = gameSettings;
        const playerIds = Object.keys(lobby.public.players);
        lobby.public.playerOrder = utils.shuffleArray(playerIds);
        lobby.public.turns = [];
        
        const numPlayers = playerIds.length;
        const gameWords = wordUtils.getGameWords(numPlayers, gameSettings.wordBankSize);
        lobby.public.startWord = gameWords.startWord;
        
        lobby.private = {};
        for (let i = 0; i < numPlayers; i++) {
            const playerId = playerIds[i];
            lobby.private[playerId] = { targetWords: gameWords.playerWordLists[i] };
        }

        lobby.internal.availableWords = gameWords.availableWords;
        
        startNextTurnOrEndGame(lobby);
    };

    return updateLobby(lobbyId, validateLobbyFn, updateLobbyFn);
});

exports.submitWord = functions.https.onCall(async (data, context) => {
    let playerId = validation.getUid(context);
    let word = validation.getWord(data);
    let lobbyId = await lobbyUtils.findLobbyIdFromUID(playerId);

    const validateLobbyFn = lobby => {
        if (lobby.public.status !== 'SUBMISSION') {
            return new functions.https.HttpsError("failed-precondition",
                `Lobby with id ${lobbyId} not awaiting word submission.`);
        }

        const turnList = lobby.public.turns;
        const currTurn = turnList[turnList.length - 1];
        if (currTurn.player !== playerId) {
            const activePlayer = lobby.public.players[currTurn.player].displayName;
            return new functions.https.HttpsError("failed-precondition",
                `Not your turn: awaiting word submission from ${activePlayer}.`);
        }

        return null;
    };

    const updateLobbyFn = lobby => {
        const currTurn = lobby.public.turns[lobby.public.turns.length - 1];
        currTurn.submittedWord = word;
        lobby.public.votesTallied = 0;
        
        // check if submitted word is other player's target word
        for (const otherId in lobby.private) {
            if (otherId === playerId) {
                continue;
            }
            if (lobby.private[otherId].targetWords.includes(word)) {
                currTurn.wasOthersWord = true;
                currTurn.otherId = otherId;
                scoreTurn(lobby);
                // TODO: generate new word for Other?
                startNextTurnOrEndGame(lobby);
                return;
            }
        }
        
        lobby.public.status = "VOTING";
        return;
    };

    return updateLobby(lobbyId, validateLobbyFn, updateLobbyFn);
});

exports.requestNewWords = functions.https.onCall(async (data, context) => {
    const playerId = validation.getUid(context);
    const lobbyId = await lobbyUtils.findLobbyIdFromUID(playerId);

    let validateLobbyFn = lobby => {
        if (lobby.public.status === 'VOTING') {
            const currTurn = lobby.public.turns[lobby.public.turns.length - 1];
            if (currTurn.player === playerId) {
                return new functions.https.HttpsError("failed-precondition",
                    `Cannot request new words during voting for your turn.`);
            }
            // if it's not your turn you can request new words during voting, so no error.
        } else if (lobby.public.status !== 'SUBMISSION') {
            return new functions.https.HttpsError("failed-precondition",
                `Cannot request new words in lobby ${lobbyId} at this time.`);
        }

        return null;
    };

    const updateLobbyFn = lobby => {
        const wordBankSize = lobby.public.settings.wordBankSize;
        const ditchedWords = lobby.private[playerId].targetWords;
        const freshWords = lobby.internal.availableWords.splice(0, wordBankSize);

        lobby.private[playerId].targetWords = freshWords;
        lobby.internal.availableWords = utils.shuffleArray(lobby.internal.availableWords.concat(ditchedWords));
        
        lobby.public.players[playerId].score -= 1;
    };

    return updateLobby(lobbyId, validateLobbyFn, updateLobbyFn);
});

exports.voteOnWord = functions.https.onCall(async (data, context) => {
    const playerId = validation.getUid(context);
    const vote = validation.getVote(data);
    const lobbyId = await lobbyUtils.findLobbyIdFromUID(playerId);

    let validateLobbyFn = lobby => {
        if (lobby.public.status !== 'VOTING') {
            return new functions.https.HttpsError("failed-precondition",
                `Lobby with id ${lobbyId} not in voting stage.`);
        }

        const currTurn = lobby.public.turns[lobby.public.turns.length - 1];
        if (currTurn.player === playerId) {
            return new functions.https.HttpsError("failed-precondition",
                `Cannot vote on your own word.`);
        }

        if (lobby.internal.votes && lobby.internal.votes[playerId]) {
            return new functions.https.HttpsError("failed-precondition",
                `Already voted.`);
        }

        return null;
    };

    const updateLobbyFn = lobby => {
        if (!lobby.internal.votes) {
            lobby.internal.votes = {};
        }
        lobby.internal.votes[playerId] = vote;
        lobby.public.votesTallied++;

        const numVotes = Object.keys(lobby.internal.votes).length;
        const numPlayers = lobby.public.playerOrder.length;
        if (numVotes === numPlayers - 1) {
            const currTurn = lobby.public.turns[lobby.public.turns.length - 1];
            currTurn.votes = lobby.internal.votes;
            const targetWords = lobby.private[currTurn.player].targetWords;
            currTurn.wasSubmittersWord = targetWords.includes(currTurn.submittedWord);
            scoreTurn(lobby);

            lobby.internal.votes = {};
            startNextTurnOrEndGame(lobby);
        }
    };

    return updateLobby(lobbyId, validateLobbyFn, updateLobbyFn);
});