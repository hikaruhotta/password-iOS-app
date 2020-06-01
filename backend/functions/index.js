const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const lobbyUtils = require('./lobby-utils');
const validation = require('./validation');
const utils = require('./utils');

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

/**
 * Helper function that modifies the passed in lobby object in-place.
 * Figures out whose turn it is and adds an in-progress turn to the turn list.
 */
function pushNextTurn(lobby) {
    const playerOrder = lobby.public.playerOrder;
    const numPlayers = playerOrder.length;
    const numTurnsSoFar = lobby.public.turns.length;
    
    const nextPlayer = playerOrder[numTurnsSoFar % numPlayers];
    const now = admin.database.ServerValue.TIMESTAMP;
    lobby.public.turns.push({ player: nextPlayer, created: now });
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
        const playerIds = Object.keys(lobby.public.players);
        lobby.public.playerOrder = utils.shuffleArray(playerIds);
        lobby.public.startWord = "password";
        lobby.public.turns = [];
        
        lobby.private = {};
        let offset = Math.floor(Math.random() * 12);
        for (const [index, uid] of lobby.public.playerOrder.entries()) {
            let targetWords = utils.tempWordlists[(index + offset) % 12];
            lobby.private[uid] = { targetWords: targetWords };
        }
        
        lobby.public.status = "SUBMISSION";
        pushNextTurn(lobby);
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
                lobby.public.status = "SUBMISSION";
                pushNextTurn(lobby);
                return;
            }
        }
        
        lobby.public.status = "VOTING";
        return;
    };

    return updateLobby(lobbyId, validateLobbyFn, updateLobbyFn);
});

exports.voteOnWord = functions.https.onCall(async (data, context) => {
    let playerId = validation.getUid(context);
    let vote = validation.getVote(data);
    let lobbyId = await lobbyUtils.findLobbyIdFromUID(playerId);

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
            lobby.public.status = 'SUBMISSION';
            pushNextTurn(lobby);
        }
    };

    return updateLobby(lobbyId, validateLobbyFn, updateLobbyFn);
});