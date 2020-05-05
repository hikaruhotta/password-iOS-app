//
//  ProfileButton.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/5/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

class ProfileButton: UIButton {

    var imageName : String!
    var borderColor : CGColor!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.layer.borderWidth = 5.0
        
        
        randomizeProfile()
        
    }
    
    
    
    
    func randomizeProfile() {
        
        self.imageName = LOCAL.imageNames[Int.random(in: 0..<LOCAL.imageNames.count)]
        self.setBackgroundImage(UIImage(named: imageName), for: .normal)
        
        self.borderColor = LOCAL.colors[Int.random(in: 0..<LOCAL.colors.count)]
        self.layer.borderColor = self.borderColor
    }
    
    
    
    

}
