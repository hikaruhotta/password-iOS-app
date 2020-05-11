const functions = require('firebase-functions');
const admin = require('firebase-admin');

// https://firebase.google.com/docs/functions/get-started for examples
admin.initializeApp();

function generateLobbyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    let code = '';
    for (let i = 0; i < 4; i++) {
        code += chars[Math.floor(Math.random() * 26)];
    }
    return code;
}

async function createLobbyCodeMapping(lobbyId, timestamp) {
    let transactionError;
    return admin.database().ref('/lobbyCodeMap/').transaction(lobbyCodeMap => {
        if (!lobbyCodeMap) {
            lobbyCodeMap = {};
        }
        
        const ONE_HOUR_MS = 3600000;
        let freeCode = null;
        for (let i = 0; i < 1000; i++) {
            let currCode = generateLobbyCode();
            if (!(currCode in lobbyCodeMap) || now - lobbyCodeMap[currCode].created < ONE_HOUR_MS) {
                freeCode = currCode;
                break;
            }
        }
        if (!freeCode) {// couldn't find a lobby code, abort transaction and throw error below.
            transactionError = new functions.https.HttpsError("resource-exhausted",
                `Could not find a free lobby code in 1000 attempts.`);
            return undefined;
        }
        
        let newMapping = { lobbyId: lobbyId, created: timestamp };
        lobbyCodeMap[freeCode] = newMapping;
        lobbyCodeMap.mostRecent = freeCode;
        return lobbyCodeMap;
    }).then(result => {
        if (!result.committed) {
            throw transactionError;
        }
        let lobbyCodeMap = result.snapshot.val();
        return lobbyCodeMap.mostRecent;
    });
}

/** 
 * Try to find lobby id associated with a given lobby code.
 * Returns a promise that resolves with the id if found or rejects with an error if not.
 */
async function getLobbyIdFromCode(lobbyCode) {
    const mappingRef = admin.database().ref('/lobbyCodeMap/' + lobbyCode.toUpperCase());
    return mappingRef.once('value').then(snapshot => {
        if (!snapshot.exists()) {
            throw new functions.https.HttpsError("not-found",
                `Mapping for lobby code ${lobbyCode} not found.`);
        } else {
            let mapping = snapshot.val();
            return mapping.lobbyId;
        }
    });
}

function validateUser(user) {
    if (!user) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing user object.`);
    }
    if (!user.username) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing username.`);
    }
}

/**
 * Try to add a user to the lobby with id `lobbyId`.
 * Returns promise that resolves on addition or rejects with error if lobby missing or closed.
 * Assumes user object is valid.
 */
async function addUserToLobby(lobbyId, user, uid) {
    const lobbyRef = admin.database().ref('/lobbies/' + lobbyId);
    let transactionError;
    return lobbyRef.transaction(lobby => {
        if (lobby === null) {
            /* When the path /lobbies/lobbyId doesn't exist, the value of `lobby` passed into the transaction
             * callback will be null. However, we shouldn't abort the transaction when that happens, as
             * that can happen in some other transaction-edge-case scenarios. But in those situations,
             * the transaction won't complete, while when the path doesn't exist, it will.
             * So, return null in the transaction if lobby is null, then if the transaction completes and 
             * the snapshot is still null, we know that lobbyId is missing and can throw our error here. */
            transactionError = new functions.https.HttpsError("not-found",
                `Lobby with id ${lobbyId} not found.`);
            return null;
        }
        if (lobby.status !== 'LOBBY') {
            transactionError = new functions.https.HttpsError("failed-precondition",
                `Lobby with id ${lobbyId} is no longer open to join.`);
            return undefined;
        }
        
        if (!lobby.users) {
            lobby.users = [];
        }
        lobby.users.push({uid: uid, username: user.username}); // Array.push, not ref().push
        return lobby;
    }).then(result => {
        if (!result.committed || !result.snapshot.exists()) {
            throw transactionError;
        }
        return result.snapshot.val();
    });
}

exports.createLobby = functions.https.onCall(async (data, context) => {
    console.log(context);
    if (!(context.auth && context.auth.uid)) {
        throw new functions.https.HttpsError('unauthenticated',
            `Missing Firebase authentication information in request.`);
    }
    const now = admin.database.ServerValue.TIMESTAMP;
    let uid = context.auth.uid;
    let user = data.user;
    validateUser(user);
    
    const lobbyCreation = admin.database().ref('/lobbies/').push({
        status: "LOBBY", created: now, hostId: uid
    });
    // lobbyInitialization is a "ThenableReference";
    // a promise whose .key property can be accessed immediately
    const lobbyId = lobbyCreation.key;
    
    const hostAdding = lobbyCreation.then(() => {
        return addUserToLobby(lobbyId, user, uid);
    });
    
    const lobbyCodeCreation = createLobbyCodeMapping(lobbyId, now);
    
    // this waits for everything: lobby created, host added, and lobby code created
    return Promise.all([hostAdding, lobbyCodeCreation]).then(values => {
        // console.log("lobbyCreation result:", values[0]);
        // console.log("lobbyCodeCreation result:", values[1]);
        newLobbyCode = values[1];
        return { lobbyId:lobbyId, lobbyCode:newLobbyCode };
    });
    
});

exports.joinLobby = functions.https.onCall(async (data, context) => {
    console.log(context);
    if (!(context.auth && context.auth.uid)) {
        throw new functions.https.HttpsError('unauthenticated',
            `Missing Firebase authentication information in request.`);
    }
    let uid = context.auth.uid;
    let lobbyCode = data.lobbyCode;
    if (!lobbyCode || lobbyCode.length !== 4) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing or invalid lobby code.`);
    }
    let user = data.user;
    validateUser(user);

    const lobbyId = await getLobbyIdFromCode(lobbyCode);
    await addUserToLobby(lobbyId, user, uid);
    return { lobbyId: lobbyId };
});


exports.startGame = functions.https.onCall(async (data, context) => {
    if (!(context.auth && context.auth.uid)) {
        throw new functions.https.HttpsError('unauthenticated',
            `Missing Firebase authentication information in request.`);
    }
    
    let uid = context.auth.uid;

    let lobbyId = data.lobbyId;
    if (!lobbyId) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing lobby id.`);
    }

    const lobbyRef = admin.database().ref('/lobbies/' + lobbyId);
    let transactionError;
    return lobbyRef.transaction(lobby => {
        if (lobby === null) {
            // See addUserToLobby for detailed description of this case,
            // and why we didn't return undefined in the transaction.
            transactionError = new functions.https.HttpsError("not-found",
                `Lobby with id ${lobbyId} not found.`);
            return null;
        }
        if (lobby.hostId !== uid) {
            transactionError = new functions.https.HttpsError("permission-denied",
                `You are not the host of the lobby with id ${lobbyId}.`);
            return undefined;
        }
        if (lobby.status !== 'LOBBY') {
            transactionError = new functions.https.HttpsError("failed-precondition",
                `Lobby with id ${lobbyId} already started.`);
            return undefined;
        }
        lobby.status = "GAME";        
        return lobby;
    }).then(result => {
        if (!result.committed || !result.snapshot.exists()) {
            throw transactionError;
        }
        return result.snapshot.val();
    }).then(lobby => {
        let createWordListPromises = [];
        for (let i = 0; i < lobby.users.length; i++) {
            const user = lobby.users[i];
            privateInfoRef = lobbyRef.child("privateInfo/" + user.uid);
            let newPrivateInfo = {words: ["quick", "brown", "fox", "jump", "dog"]};
            createWordListPromises.push(privateInfoRef.set(newPrivateInfo));
        }
        return Promise.all(createWordListPromises);
    });

});