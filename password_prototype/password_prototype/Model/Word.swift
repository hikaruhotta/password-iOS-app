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
    var timeStamp: String?
    var score: Int?
    var vetoCount: [String]?
    
    init(word: String, user: String, timeStamp: String, score: Int, vetoCount:[String]) {
        self.word = word
        self.user = user
        self.timeStamp = timeStamp
        self.score = score
        self.vetoCount = ["user"]
    }
    
    init(dictionary: [String : Any] ) {
        self.word = dictionary["word"] as? String
        self.user = dictionary["user"] as? String
        self.timeStamp = dictionary["timeStamp"] as? String
        self.score = dictionary["score"] as? Int
        self.vetoCount = dictionary["vetoCount"] as? [String]
        
    }
    
    func constructDict() -> Dictionary<String, Any> {
        let dict  = [
            "word" : word!,
            "user" : user!,
            "timeStamp" : timeStamp!,
            "score" : score!,
            "vetoCount" : vetoCount!
        ] as [String : Any]
        return dict
    }
    
    
}
