//
//  UserSmallIconButton.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/4/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

class UserSmallIconButton: UIButton {
    
    func setUserIcon(user: User) {
        self.layer.cornerRadius = (self.frame.size.width ) / 2
        self.clipsToBounds = true
        self.layer.borderWidth = 3.0
        self.setTitle(LOCAL.emojis[user.emojiNumber], for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: self.frame.height * 0.75)
        self.layer.borderColor = LOCAL.colors[user.colorNumber]
    }
    
}
