//
//  ProfileButton.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/5/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

@IBDesignable
class ProfileButton: UIButton {
    
    
    @IBInspectable
    var borderWidth: CGFloat = 5.0 {
        didSet {
            setBorderWidth(borderWidth: borderWidth)
        }
    }
    
    func setBorderWidth(borderWidth: CGFloat) {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.layer.borderWidth = borderWidth
    }
    
    func reloadButton() {
        self.setTitle(LOCAL.emojis[LOCAL.user.emojiNumber], for: .normal)
        self.layer.borderColor = LOCAL.colors[LOCAL.user.colorNumber]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel?.font = UIFont.systemFont(ofSize: self.frame.height * 0.75)
        reloadButton()
    }
    
    
    
    
}
