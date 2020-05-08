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
    var content: String?
    var timeStamp: String?
    
    init(dictionary: [String : Any] ) {
        self.user = dictionary["user"] as? String
        self.content = dictionary["content"] as? String
        self.timeStamp = dictionary["timeStamp"] as? String
    }
}
