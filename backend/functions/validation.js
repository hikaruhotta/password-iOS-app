const functions = require('firebase-functions');

exports.getPlayer = function (data) {
    const player = data.player;
    if (!player) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing player object.`);
    }
    if (!player.displayName) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing player.displayName.`);
    }
    if (player.colorNumber === undefined) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing player.colorNumber.`);
    }
    if (player.emojiNumber === undefined) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing player.emojiNumber.`);
    }
    return player;
}

exports.getUid = function (context) {
    const uid = context.auth && context.auth.uid;
    if (!uid) {
        throw new functions.https.HttpsError('unauthenticated',
            `Missing Firebase authentication information in request.`);
    }
    return uid;
}

exports.getWord = function (data) {
    const word = data.word;
    if (!word) {
        throw new functions.https.HttpsError('invalid-argument',
            `Missing word in submitWord request.`);
    }

    const alphabet = /^[a-z]+$/i;
    if (!alphabet.exec(word)) {
        throw new functions.https.HttpsError('invalid-argument',
            `Submitted word contains disallowed characters.`);
    }
    return word;
}

exports.getChallenge = function (data) {
    const challenge = data.challenge;
    if (challenge === undefined) {
        throw new functions.https.HttpsError('invalid-argument',
            `Missing vote in voteOnWord request.`);
        }
    return challenge;
}

exports.getLobbyCode = function (data) {
    const lobbyCode = data.lobbyCode;
    if (!lobbyCode || lobbyCode.length !== 4) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing or invalid lobby code.`);
    }
    return lobbyCode;
}