//
//  Message.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/7/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import Foundation

struct Message {
    var userID: String?
    var message: String?
    var timeStamp: String?
    
    init(userID: String, message: String, timeStamp: String) {
        self.userID = userID
        self.message = message
        self.timeStamp = timeStamp
    }
    
    init(dictionary: [String : Any] ) {
        self.userID = dictionary["userID"] as? String
        self.message = dictionary["message"] as? String
        self.timeStamp = dictionary["timeStamp"] as? String
    }
    
    func toDictionary(){
        var dict = [String:Any]()
        dict["user"] = self.userID
        dict["message"] = self.message
        dict["timeStamp"] = self.timeStamp
    }
    
}
