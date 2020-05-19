//
//  Lobby.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/10/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import Foundation

struct Lobby {
    var lobbyId : String
    var lobbyCode : String

    
    init(dictionary: [String: String]) {
        self.lobbyId = dictionary["lobbyId"] ?? ""
        self.lobbyCode = dictionary["lobbyCode"] ?? ""
        
    }
    
    func initDirs(dictionary: [String : Any]) {
        
    }
    

}
