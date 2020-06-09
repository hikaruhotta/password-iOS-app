//
//  LobbyFB.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/19/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import Foundation

struct LobbyFB {
    
    var internalDir : [String: Any]?     // create#, hostID, status
    var privateDir : [String : Any]?    // player word banks
    var publicDir : [String : Any]?    // order, playerlist, turns, seed word
    
    init(dictionary: [String: Any]) {
    }
    

}
