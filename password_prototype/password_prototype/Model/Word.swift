//
//  Word.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/5/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import Foundation

struct Word : Identifiable {
    
    var id: Int
    var word: String?
    var created: Int?
    var player: User?
    var wasChallenged: Bool?
    var wasSubmittersWord: Bool?
    
    init(dictionary: [String : Any] ) {
        self.created = dictionary["created"] as? Int
        self.id = self.created ?? 0
        
        let id = dictionary["player"] as? String
        self.player = LOCAL.users.getUserFromID(id: id!)
        
        self.word = dictionary["submittedWord"] as? String
        self.wasChallenged = dictionary["wasChallenged"] as? Bool
        self.wasSubmittersWord = dictionary["wasSubmiiteresWord"] as? Bool
    }
    
}

extension Collection where Element: Identifiable {
    func firstIndex(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
}
