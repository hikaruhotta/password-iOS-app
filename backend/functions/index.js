const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');

// https://firebase.google.com/docs/functions/get-started for examples
admin.initializeApp();

function createLobbyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    let code = '';
    for (let i = 0; i < 4; i++) {
        code += chars[Math.floor(Math.random() * 26)];
    }
    return code;
}


exports.createLobby = functions.https.onRequest(async (req, res) => {
    const now = admin.database.ServerValue.TIMESTAMP;
    const hostSecret = crypto.randomBytes(16).toString('hex');
    const lobbyCode = createLobbyCode();

    // TODO check if push fails
    const lobbyRef = admin.database().ref('/lobbies/').push({
        status: "LOBBY", users: {}, created: now, key: hostSecret
    });
    const lobbyId = lobbyRef.key;
    
    admin.database().ref('/lobbyCodeMap/' + lobbyCode).transaction((existingMapping) => {
        if (existingMapping === null || now - existingMapping.created > 3600000) {
            return { lobbyId: lobbyId, created: now };
        } else {
            return undefined; // abort transaction
        }
    }, (error, committed, snapshot) => {
        if (error) {
          console.log("Error creating lobby code: ", error);
        } else if (!committed) {
          console.log("Didn't create lobby code mapping: code taken");
        } else {
          console.log('Created lobby code mapping.');
        }
        console.log("Mapping: ", snapshot.val());
    });

    res.status(201).set("Location", lobbyRef.toString()).json({hostKey: hostSecret});

});

// WIP
// exports.joinLobby = functions.https.onRequest(async (req, res) => {
    
//     const username = req.query.username;
//     if (!username) {
//         res.status(400).send("Missing username in request.");
//         return;
//     }

// });