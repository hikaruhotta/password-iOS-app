//
//  Database.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/4/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import Foundation

class MyDatabase {
    var lobbies: [Lobby] = []
    init() {
        lobbies.append(Lobby())
    }
    func addLobby(_ lobbyName: Lobby) {
        lobbies.append(lobbyName)
    }
}

class Lobby {
    var players: [String]
    = []
    //var submittedWords
    var lobbyID: String = "ABCD"
    init() {
        self.addPlayer("philip")
        self.addPlayer("hikaru")
        self.addPlayer("buck")
        self.addPlayer("nick")
    }
    func addPlayer(_ name: String) {
        players.append(name)
    }
}

var db = MyDatabase()




