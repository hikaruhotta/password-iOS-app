//
//  User.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/10/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import Foundation

struct User {
    var username: String
    var colorNumber: Int
    var emojiNumber: Int
    var score: Int
    
    init(dictionary: [String: String]){
        self.username = dictionary["username"] ?? ""
        self.colorNumber = Int(dictionary["colorNumber"] ?? "0") ?? 0
        self.emojiNumber = Int(dictionary["emojiNumber"] ?? "0") ?? 0
        self.score = Int(dictionary["score"] ?? "0") ?? 0
    }
}
