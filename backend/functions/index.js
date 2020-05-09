const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');

// https://firebase.google.com/docs/functions/get-started for examples
admin.initializeApp();

function randomLobbyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    let code = '';
    for (let i = 0; i < 4; i++) {
        code += chars[Math.floor(Math.random() * 26)];
    }
    return code;
}


exports.createLobby = functions.https.onCall((data, context) => {
    const now = admin.database.ServerValue.TIMESTAMP;
    const hostSecret = crypto.randomBytes(16).toString('hex');
    
    const lobbyCreation = admin.database().ref('/lobbies/').push({
        status: "LOBBY", users: {}, created: now, key: hostSecret
    });
    // lobbyCreation is a "ThenableReference"; a promise whose .key property can be accessed immediately
    const lobbyId = lobbyCreation.key;
    
    const lobbyCodeCreation = admin.database().ref('/lobbyCodeMap/').transaction(lobbyCodeMap => {
        // due to how transactions work, lobbyCodeMap could be null.
        // most such transactions will be discarded, but account for it anyway.
        if (!lobbyCodeMap) {
            lobbyCodeMap = {};
        }

        const ONE_HOUR_MS = 3600000;
        let freeCode = null;
        for (let i = 0; i < 1000; i++) {
            let currCode = randomLobbyCode();
            if (!(currCode in lobbyCodeMap) || now - lobbyCodeMap[currCode].created < ONE_HOUR_MS) {
                freeCode = currCode;
                break;
            }
        }
        if (!freeCode) {
            throw new functions.https.HttpsError("resource-exhausted", "Could not find a free lobby code in 1000 attempts.");
        }

        let newMapping = { lobbyId: lobbyId, created: now };
        lobbyCodeMap[freeCode] = newMapping;
        return lobbyCodeMap;
    });

    // wait for lobby and code to be created
    return Promise.all([lobbyCreation, lobbyCodeCreation]).then(values => {
        // console.log("lobbyCreation result:", values[0]);
        // console.log("lobbyCodeCreation result:", values[1]);
        return { lobbyId:lobbyId, hostSecret:hostSecret };
    }, error => {
        console.error(`Error when creating lobby: ${error}`);
    });

});