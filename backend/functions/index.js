const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const validation = require('./validation');
const lobbyUtils = require('./lobby-utils');
const gameLogic = require('./game-logic');

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
        lobby.internal.transactionTime = admin.database.ServerValue.TIMESTAMP;
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
    const player = validation.getPlayerInfo(data);
    
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
    const playerInfo = validation.getPlayerInfo(data);
    const lobbyCode = validation.getLobbyCode(data);
    const lobbyId = await lobbyUtils.findLobbyIdFromCode(lobbyCode);
    
    await addPlayerToLobby(lobbyId, playerInfo, playerId);
    return { lobbyId: lobbyId };
});

exports.startGame = functions.https.onCall(async (data, context) => {
    const gameSettings = validation.getGameSettings(data);
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
        lobby.public.settings = gameSettings;
        
        let newStatus = gameLogic.initializeGame(lobby);
        lobby.public.status = newStatus;
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

        const currTurn = lobby.public.turns[lobby.public.turns.length - 1];
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

        const newStatus = gameLogic.handleWordSubmission(lobby);
        lobby.public.status = newStatus;
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
        gameLogic.assignNewWords(lobby, playerId);
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

        const newStatus = gameLogic.handleVote(lobby);
        lobby.public.status = newStatus;
    };

    return updateLobby(lobbyId, validateLobbyFn, updateLobbyFn);
});