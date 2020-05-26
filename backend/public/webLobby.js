
// firebase.functions().useFunctionsEmulator("http://localhost:5001");
firebase.auth().signInAnonymously();

var pageLobbyId;

function dummyPlayer() {
    const displayName = document.getElementById("displayName").value;
    return {
        displayName: displayName,
        colorNumber: 3,
        emojiNumber: 4
    };
}

document.getElementById("createLobby").onclick = function() {
    let createLobby = firebase.functions().httpsCallable('createLobby');
    createLobby({player: dummyPlayer()}).then(result => {
        console.log(result);
        pageLobbyId = result.data.lobbyId;
        document.getElementById("lobbyCodeDisplay").value = result.data.lobbyCode;
        createLobbyListener(pageLobbyId);
        
    });
};

document.getElementById("joinLobby").onclick = function() {
    const lobbyCode = document.getElementById("lobbyCodeEntry").value;
    
    let joinLobby = firebase.functions().httpsCallable('joinLobby');
    joinLobby({lobbyCode: lobbyCode, player: dummyPlayer()}).then(result => {
        console.log(result);
        pageLobbyId = result.data.lobbyId;
        document.getElementById("lobbyCodeDisplay").value = lobbyCode;
        createLobbyListener(pageLobbyId);
    });
}

document.getElementById("startGame").onclick = function() {    
    let startGame = firebase.functions().httpsCallable('startGame');
    startGame().then(result => {
        console.log(result);
    });
}

document.getElementById("voteChallenge").onclick = function() {    
    vote(true);
}

document.getElementById("votePass").onclick = function() {    
    vote(false);
}

function vote(voteBool) {
    let voteOnWord = firebase.functions().httpsCallable('voteOnWord');
    voteOnWord({"challenge": voteBool}).then(result => {
        console.log(result);
    });
}

document.getElementById("submitWord").onclick = function() {    
    let submitWord = firebase.functions().httpsCallable('submitWord');
    let word = document.getElementById('wordEntry').value;
    submitWord({word: word}).then(result => {
        console.log(result);
    });
}

document.getElementById("copyLobbyCode").onclick = function() {
    let copyText = document.getElementById("lobbyCodeDisplay");
    copyText.select();
    document.execCommand("copy");
}

function createLobbyListener(lobbyId) {
    // console.log(lobbyId);
    const lobbyPlayers = firebase.database().ref('/lobbies/' + lobbyId + '/public/players');
    lobbyPlayers.on('value', function(snapshot) {
        console.log(snapshot.val());
        displayLobby(snapshot.val());
    });

    var uid = firebase.auth().currentUser.uid;
    const targetWords = firebase.database().ref('/lobbies/' + lobbyId + '/private/' + uid + '/targetWords');
    targetWords.on('value', function(snapshot) {
        console.log(snapshot.val());
        // displayLobby(snapshot.val());
    });
}

function displayLobby(lobby) {
    // console.log(lobby);
    
    const ul = document.getElementById("lobby");
    ul.innerHTML = ""; // reset lobby display
    for (const uid in lobby) {
        let user = lobby[uid];
        let li = document.createElement("li");
        li.appendChild(document.createTextNode(user.displayName));
        ul.appendChild(li);
    }
}