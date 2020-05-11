
firebase.functions().useFunctionsEmulator("http://localhost:5001");
firebase.auth().signInAnonymously()

var pageLobbyId;

document.getElementById("createLobby").onclick = function() {
    const username = document.getElementById("username").value;

    let createLobby = firebase.functions().httpsCallable('createLobby');
    createLobby({user: {username: username}}).then(result => {
        console.log(result);
        pageLobbyId = result.data.lobbyId;
        document.getElementById("lobbyCodeDisplay").value = result.data.lobbyCode;
        createLobbyListener(pageLobbyId);
        
    });
};

document.getElementById("joinLobby").onclick = function() {
    const username = document.getElementById("username").value;
    const lobbyCode = document.getElementById("lobbyCodeEntry").value;
    
    let joinLobby = firebase.functions().httpsCallable('joinLobby');
    joinLobby({lobbyCode: lobbyCode, user: {username: username}}).then(result => {
        console.log(result);
        pageLobbyId = result.data.lobbyId;
        document.getElementById("lobbyCodeDisplay").value = lobbyCode;
        createLobbyListener(pageLobbyId);
    });
}

document.getElementById("startGame").onclick = function() {    
    let startGame = firebase.functions().httpsCallable('startGame');
    startGame({lobbyId: pageLobbyId}).then(result => {
        console.log(result);
    });
}

document.getElementById("copyLobbyId").onclick = function() {
    let copyText = document.getElementById("lobbyIdDisplay");
    copyText.select();
    document.execCommand("copy");
}

function createLobbyListener(lobbyId) {
    // console.log(lobbyId);
    const lobbyUsers = firebase.database().ref('/lobbies/' + lobbyId + '/users');
    lobbyUsers.on('value', function(snapshot) {
        console.log(snapshot.val());
        displayLobby(snapshot.val());
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