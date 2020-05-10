//
//  Lobby.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/10/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import Foundation

struct Lobby: Codable {
    var hostSecret : String?
    var lobbyId : String
    var lobbyCode : String
  
    
    init(dictionary: [String: String]) {
        self.hostSecret = dictionary["hostSecret"] ?? ""
        self.lobbyId = dictionary["lobbyId"] ?? ""
        self.lobbyCode = dictionary["lobbyCode"] ?? ""
    }
    
//    init?(json: Data?) {
//        print("creating lobby?")
//        if json != nil, let newLobby = try? JSONDecoder().decode(Lobby.self, from: json!) {
//            print("assigning lobby?")
//            self = newLobby
//        } else {
//            return nil
//        }
//    }
}
