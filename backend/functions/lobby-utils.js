const functions = require('firebase-functions');
const admin = require('firebase-admin');

function generateLobbyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    let code = '';
    for (let i = 0; i < 4; i++) {
        code += chars[Math.floor(Math.random() * 26)];
    }
    return code;
}

exports.createLobbyCodeMapping = async function(lobbyId, timestamp) {
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
        
        const newMapping = { lobbyId: lobbyId, created: timestamp };
        lobbyCodeMap[freeCode] = newMapping;
        lobbyCodeMap.mostRecent = freeCode;
        return lobbyCodeMap;
    }).then(result => {
        if (!result.committed) {
            throw transactionError;
        }
        const lobbyCodeMap = result.snapshot.val();
        return lobbyCodeMap.mostRecent;
    });
}

/** 
 * Try to find lobby id associated with a given lobby code.
 * Returns a promise that resolves with the id if found or rejects with an error if not.
 */
exports.findLobbyIdFromCode = async function(lobbyCode) {
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

/**
 * When a player joins a lobby we store the current lobbyId associated with their uid.
 * Checks the mapping to find a player's current lobby, returning a promise with the result.
 */
exports.findLobbyIdFromUID = async function(uid) {
    return admin.database().ref('/playerLobbyMap/' + uid).once('value').then(snapshot => {
        if (!snapshot.exists()) {
            throw new functions.https.HttpsError("internal",
                `Could not find current lobby for user ${uid}.`)
        }
        return snapshot.val();
    });
}