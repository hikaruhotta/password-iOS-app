const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');

// https://firebase.google.com/docs/functions/get-started for examples
admin.initializeApp();

function generateLobbyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    let code = '';
    for (let i = 0; i < 4; i++) {
        code += chars[Math.floor(Math.random() * 26)];
    }
    return code;
    // return "ASDF";
}

async function createLobbyCodeMapping(lobbyId, timestamp) {
    let code;
    return admin.database().ref('/lobbyCodeMap/').transaction(lobbyCodeMap => {
        // due to how transactions work, lobbyCodeMap could be null.
        // most such transactions will be discarded, but account for it anyway.
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
        if (!freeCode) {
            return; // couldn't find a lobby code, abort transaction and throw error below.
        }
        
        let newMapping = { lobbyId: lobbyId, created: timestamp };
        lobbyCodeMap[freeCode] = newMapping;
        lobbyCodeMap.mostRecent = freeCode;
        return lobbyCodeMap;
    }).then(result => {
        if (!result.committed) {
            throw new functions.https.HttpsError("resource-exhausted",
            "Could not find a free lobby code in 1000 attempts.");
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
            throw new functions.https.HttpsError("not-found", `Mapping for lobby code ${lobbyCode} not found.`);
        } else {
            let mapping = snapshot.val();
            return mapping.lobbyId;
        }
    });
}

function validateUser(user) {
    if (!user) {
        throw new functions.https.HttpsError("invalid-argument", `Missing user object.`);
    }
    if (!user.username) {
        throw new functions.https.HttpsError("invalid-argument", "Missing username.");
    }
}

/**
 * Try to add a user to the lobby with id `lobbyId`.
 * Returns promise that resolves on addition or rejects with error if lobby missing or closed.
 * Assumes user object is valid.
 */
async function addUserToLobby(lobbyId, user) {
    const lobbyRef = admin.database().ref('/lobbies/' + lobbyId);
    return lobbyRef.transaction(lobby => {
        if (lobby === null) {
            return null;
        }
        if (lobby.status !== 'LOBBY') {
            return; // lobby closed, abort transaction and throw error in callback below
        }
        
        if (!lobby.users) {
            lobby.users = [];
        }
        lobby.users.push(user);
        return lobby;
        
    }).then(result => {
        if (!result.committed) {
            throw new functions.https.HttpsError("failed-precondition", `Lobby with id ${lobbyId} is no longer open to join.`);
        }
        /* When the path /lobbies/lobbyId doesn't exist, the value of `lobby` passed into the transaction
         * callback will be null. However, we shouldn't abort the transaction when that happens, as
         * that can happen in some other transaction-edge-case scenarios. But in those situations,
         * the transaction won't complete, while when the path doesn't exist, it will.
         * So, return null in the transaction if lobby is null, then if the transaction completes and 
         * the snapshot is still null, we know that lobbyId is missing and can throw our error here. */
        if (!result.snapshot.exists()) {
            let error = new functions.https.HttpsError("internal", `Lobby with id ${lobbyId} not found.`);
            console.error(error);
            throw error;
        }
    });
}

exports.createLobby = functions.https.onCall(async (data, context) => {
    const now = admin.database.ServerValue.TIMESTAMP;
    let user = data.user;
    validateUser(user);
    
    const hostSecret = crypto.randomBytes(16).toString('hex');
    const lobbyCreation = admin.database().ref('/lobbies/').push({
        status: "LOBBY", created: now, key: hostSecret
    });
    // lobbyInitialization is a "ThenableReference";
    // a promise whose .key property can be accessed immediately
    const lobbyId = lobbyCreation.key;
    
    const hostAdding = lobbyCreation.then(() => {
        return addUserToLobby(lobbyId, user);
    });
    
    const lobbyCodeCreation = createLobbyCodeMapping(lobbyId, now);
    
    // this waits for everything: lobby created, host added, and lobby code created
    return Promise.all([hostAdding, lobbyCodeCreation]).then(values => {
        // console.log("lobbyCreation result:", values[0]);
        // console.log("lobbyCodeCreation result:", values[1]);
        newLobbyCode = values[1];
        return { lobbyId:lobbyId, hostSecret:hostSecret, lobbyCode:newLobbyCode };
    });
    
});

exports.joinLobby = functions.https.onCall(async (data, context) => {
    let lobbyCode = data.lobbyCode;
    if (!lobbyCode || lobbyCode.length !== 4) {
        throw new functions.https.HttpsError("invalid-argument", `Missing or invalid lobby code.`);
    }
    let user = data.user;
    validateUser(user);

    const lobbyId = await getLobbyIdFromCode(lobbyCode);
    await addUserToLobby(lobbyId, user);
    return lobbyId;
});