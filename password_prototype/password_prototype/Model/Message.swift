//
//  Message.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/7/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import Foundation

struct Message {
    var user: String?
    var message: String?
    var timeStamp: String?
    
    init(user: String, message: String, timeStamp: String) {
        self.user = user
        self.message = message
        self.timeStamp = timeStamp
    }
    
    init(dictionary: [String : Any] ) {
        self.user = dictionary["user"] as? String
        self.message = dictionary["message"] as? String
        self.timeStamp = dictionary["timeStamp"] as? String
    }
    
    func constructDict() -> Dictionary<String, Any> {
        let dict  = [
            "user" : user!,
            "message": message!,
            "timeStamp" : timeStamp!,
        ] as [String : Any]
        return dict
    }
    
}
