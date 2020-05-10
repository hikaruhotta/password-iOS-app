"use strict";

firebase.functions().useFunctionsEmulator("http://localhost:5001");

document.getElementById("createLobby").onclick = function() {
    const username = document.getElementById("username").value;

    let createLobby = firebase.functions().httpsCallable('createLobby');
    createLobby({user: {username: username}}).then(result => {
        // console.log(result);
        let lobbyId = result.data.lobbyId;
        createLobbyListener(lobbyId);
        document.getElementById("lobbyCodeDisplay").value = result.data.lobbyCode;
        
    });
};

document.getElementById("joinLobby").onclick = function() {
    const username = document.getElementById("username").value;
    const lobbyCode = document.getElementById("lobbyCodeEntry").value;
    
    let joinLobby = firebase.functions().httpsCallable('joinLobby');
    joinLobby({lobbyCode: lobbyCode, user: {username: username}}).then(result => {
        // console.log(result);
        let lobbyId = result.data.lobbyId;
        document.getElementById("lobbyCodeDisplay").value = lobbyCode;
        createLobbyListener(lobbyId);
    });
}

document.getElementById("copyLobbyId").onclick = function() {
    let copyText = document.getElementById("lobbyIdDisplay");
    copyText.select();
    document.execCommand("copy");
}

function createLobbyListener(lobbyId) {
    // console.log(lobbyId);
    const lobbyRef = firebase.database().ref('/lobbies/' + lobbyId);
    lobbyRef.on('value', function(snapshot) {
        // console.log(snapshot.val());
        displayLobby(snapshot.val().users);
    });
}

function displayLobby(lobby) {
    // console.log(lobby);
    
    const ul = document.getElementById("lobby");
    ul.innerHTML = ""; // reset lobby display
    for (let i = 0; i < lobby.length; i++) {
        const user = lobby[i];
        let li = document.createElement("li");
        li.appendChild(document.createTextNode(user.username));
        ul.appendChild(li);
    }
}