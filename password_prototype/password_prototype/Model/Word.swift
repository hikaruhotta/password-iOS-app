//
//  Word.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/5/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import Foundation

struct Word {
    var word: String?
    var user: String?
    var order: Int?
    var score: Int?
    var vetoCount: [String]?
    
    init(dictionary: [String : Any] ) {
        self.word = dictionary["word"] as? String
        self.user = dictionary["user"] as? String
        self.order = dictionary["order"] as? Int
        self.score = dictionary["score"] as? Int
        self.vetoCount = dictionary["vetoCount"] as? [String]
        
    }
}
