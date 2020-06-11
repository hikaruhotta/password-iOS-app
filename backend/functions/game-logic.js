const utils = require('./utils');
const wordUtils = require('./word-utils');

function scoreTurn (lobby) {
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

function startNextTurnOrEndGame (lobby) {
    const numTurnsTaken = lobby.public.turns.length;
    const numPlayers = lobby.public.playerOrder.length;
    const numRounds = lobby.public.settings.numRounds;

    const gameIsFinished = (numTurnsTaken === numRounds * numPlayers);
    let newStatus;
    if (gameIsFinished) {
        newStatus = "DONE";
    } else {
        // start next turn
        const nextPlayer = lobby.public.playerOrder[numTurnsTaken % numPlayers];
        if (nextPlayer.startsWith("bot")) {
            lobby.internal.awaitingBotTurn = true;
        }
        const now = lobby.internal.transactionTime;
        lobby.public.turns.push({ player: nextPlayer, created: now });
        newStatus = "SUBMISSION";
    }
    return newStatus;
}

exports.initializeGame = function (lobby) {
    const playerIds = Object.keys(lobby.public.players);
    lobby.public.playerOrder = utils.shuffleArray(playerIds);
    lobby.public.turns = [];
    
    const numPlayers = playerIds.length;
    const gameSettings = lobby.public.settings;
    const gameWords = wordUtils.getGameWords(numPlayers, gameSettings.wordBankSize);
    lobby.public.startWord = gameWords.startWord;
    
    lobby.private = {};
    for (let i = 0; i < numPlayers; i++) {
        const playerId = playerIds[i];
        lobby.private[playerId] = { targetWords: gameWords.playerWordLists[i] };
    }

    lobby.internal.availableWords = gameWords.availableWords;
    const newStatus = startNextTurnOrEndGame(lobby);
    return newStatus;
}

exports.handleWordSubmission = function (lobby) {
    const currTurn = lobby.public.turns[lobby.public.turns.length - 1];
    const submitterId = currTurn.player;
    const word = currTurn.submittedWord;

    // check if submitted word is other player's target word
    for (const otherId in lobby.private) {
        if (otherId === submitterId) {
            continue;
        }
        if (lobby.private[otherId].targetWords.includes(word)) {
            currTurn.wasOthersWord = true;
            currTurn.otherId = otherId;
            scoreTurn(lobby);
            // TODO: generate new word for Other?
            const newStatus = startNextTurnOrEndGame(lobby);
            return newStatus;
        }
    }
    
    // if this array ends up nonempty, watchForBotVotes is triggered in index.js 
    lobby.internal.awaitingBotVotes = []
    for (const playerId of Object.keys(lobby.public.players)) {
        if (playerId.startsWith("bot") && playerId !== submitterId) {
            lobby.internal.awaitingBotVotes.push(playerId);
        }
    }
    
    const newStatus = "VOTING";
    return newStatus;
}

exports.handleVote = function (lobby) {
    const numVotes = Object.keys(lobby.internal.votes).length;
    const numPlayers = lobby.public.playerOrder.length;

    let newStatus;
    const allVotesTallied = (numVotes === numPlayers - 1);
    if (allVotesTallied) {
        const currTurn = lobby.public.turns[lobby.public.turns.length - 1];
        // copy internal votes into public turn object so clients can see results
        currTurn.votes = lobby.internal.votes;
        const targetWords = lobby.private[currTurn.player].targetWords;
        currTurn.wasSubmittersWord = targetWords.includes(currTurn.submittedWord);
        scoreTurn(lobby);

        lobby.internal.votes = {};
        newStatus = startNextTurnOrEndGame(lobby);
    } else {
        newStatus = "VOTING";
    }

    return newStatus;
}

exports.assignNewWords = function (lobby, playerId) {
    const wordBankSize = lobby.public.settings.wordBankSize;
    const ditchedWords = lobby.private[playerId].targetWords;
    const freshWords = lobby.internal.availableWords.splice(0, wordBankSize);

    lobby.private[playerId].targetWords = freshWords;
    lobby.internal.availableWords = utils.shuffleArray(lobby.internal.availableWords.concat(ditchedWords));
    
    lobby.public.players[playerId].score -= 1;
}

exports.getPreviousWord = function (lobby) {
    if (numTurns === 1) {
        previousWord = lobby.public.startWord;
    } else {
        const lastTurn = lobby.public.turns[numTurns - 2];
        previousWord = lastTurn.submittedWord;
    }
}