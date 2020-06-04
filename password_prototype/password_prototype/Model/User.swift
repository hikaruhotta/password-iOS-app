//
//  User.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/10/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import Foundation

struct User {
    var displayName: String
    var colorNumber: Int
    var emojiNumber: Int
    var score: Int
    var userID: String
    var targetWords: [String]?
    
    init(dictionary: [String: Any], userID: String){
        self.displayName = dictionary["displayName"] as! String
        self.colorNumber = dictionary["colorNumber"] as! Int
        self.emojiNumber = dictionary["emojiNumber"] as! Int
        self.score = dictionary["score"] as! Int
        self.userID = userID
        self.targetWords = []
    }
    
    init(){
        self.displayName = "Anonymous"
        self.colorNumber = 0
        self.emojiNumber = 0
        self.score = 0
        self.userID = ""
        self.targetWords = []
    }
    
}

extension Array where Element == User {
    func getUserFromID (id: String) -> User? {
        for user in self {
            if user.userID == id {
                return user
            }
        }
        return nil
    }
}
