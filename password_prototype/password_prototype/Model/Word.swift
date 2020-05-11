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
    var user: User?
    var timeStamp: String?
    var score: Int?
    
    init(word: String, user: User, timeStamp: String, score: Int) {
        self.word = word
        self.user = user
        self.timeStamp = timeStamp
        self.score = score
    }
    
    init(dictionary: [String : Any] ) {
        self.word = dictionary["word"] as? String
        //print(dictionary["user"]!)
        self.user = User(dictionary: (dictionary["user"] as! [String : String]))
        self.timeStamp = dictionary["timeStamp"] as? String
        self.score = dictionary["score"] as? Int
        
    }
    
    func constructDict() -> Dictionary<String, Any> {
        let dict  = [
            "word" : word!,
            "user" : user!.constructDict(),
            "timeStamp" : timeStamp!,
            "score" : String(score!),
        ] as [String : Any]
        return dict
    }
    
    
}
