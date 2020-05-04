"use strict";

document.getElementById("createLobby").onclick = function() {
    const lobbyRef = firebase.database().ref('/lobbies/').push();
    joinLobby(lobbyRef);
};

document.getElementById("joinLobby").onclick = function() {
    const lobbyKey = document.getElementById("lobbyId").value;
    const lobbyRef = firebase.database().ref('/lobbies/' + lobbyKey);
    joinLobby(lobbyRef);
}

document.getElementById("copyLobbyId").onclick = function() {
    let copyText = document.getElementById("lobbyIdDisplay");
    copyText.select();
    document.execCommand("copy");
}

function joinLobby(lobbyRef) {
    lobbyRef.on('value', function(snapshot) {
        displayLobby(snapshot.key, snapshot.val());
    });

    const username = document.getElementById("username").value;
    lobbyRef.push({username: username});
}

function displayLobby(lobbyId, lobby) {
    document.getElementById("lobbyIdDisplay").value = lobbyId;
    const ul = document.getElementById("lobby");
    ul.innerHTML = ""; // reset lobby display
    for (const userKey in lobby) {
        const user = lobby[userKey];
        let li = document.createElement("li");
        li.appendChild(document.createTextNode(user.username));
        ul.appendChild(li);
    }
}