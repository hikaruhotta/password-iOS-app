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
    var created: Int?
    var player: User?
    
//    init(word: String, user: User, timeStamp: String, score: String) {
//        self.word = word
//        self.user = user
//        self.timeStamp = timeStamp
//        self.score = score
//    }
//
    init(dictionary: [String : Any] ) {
        self.word = dictionary["submittedWord"] as? String
        self.created = dictionary["created"] as? Int
        let id = dictionary["player"] as? String
        self.player = LOCAL.users.getUserFromID(id: id!)
    }
    
//    func constructDict() -> Dictionary<String, Any> {
//        let dict  = [
//            "word" : word!,
//            "user" : user!.constructDict(),
//            "timeStamp" : timeStamp!,
//            "score" : String(score!),
//        ] as [String : Any]
//        return dict
//    }
    
    
}
