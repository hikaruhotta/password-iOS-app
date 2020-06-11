const functions = require('firebase-functions');

exports.getPlayerInfo = function (data) {
    const playerInfo = data.player;
    if (!playerInfo) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing player object.`);
    }
    if (!playerInfo.displayName) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing player.displayName.`);
    }
    if (playerInfo.colorNumber === undefined) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing player.colorNumber.`);
    }
    if (playerInfo.emojiNumber === undefined) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing player.emojiNumber.`);
    }
    return playerInfo;
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

exports.getVote = function (data) {
    const vote = data.challenge;
    if (vote === undefined) {
        throw new functions.https.HttpsError('invalid-argument',
            `Missing vote in voteOnWord request.`);
        }
    return vote;
}

exports.getLobbyCode = function (data) {
    const lobbyCode = data.lobbyCode;
    if (!lobbyCode || lobbyCode.length !== 4) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing or invalid lobby code.`);
    }
    return lobbyCode;
}

exports.getGameSettings = function (data) {
    if (!data || !data.settings) {
        // default values
        return { numRounds: 8, wordBankSize: 6 };
    }
    const settings = data.settings;
    const numRounds = settings.numRounds;
    if (!numRounds) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing numRounds in submitted settings.`);
    }
    if (!Number.isInteger(numRounds) || numRounds < 1 ) {
        throw new functions.https.HttpsError("invalid-argument",
            `numRounds should be a positive integer.`);
    }

    const wordBankSize = settings.wordBankSize;
    if (!wordBankSize) {
        throw new functions.https.HttpsError("invalid-argument",
            `Missing wordBankSize in submitted settings.`);
    }
    if (!Number.isInteger(wordBankSize) || wordBankSize < 1 ) {
        throw new functions.https.HttpsError("invalid-argument",
            `wordBankSize should be a positive integer.`);
    }

    
    return settings;
}