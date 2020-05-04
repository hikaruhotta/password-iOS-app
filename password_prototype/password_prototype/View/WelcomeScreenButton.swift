//
//  WelcomeScreenButton.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/2/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

@IBDesignable
class WelcomeScreenButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet{
            setButton(cornerRadius: cornerRadius)
        }
    }
    
     var sampleData = ["philip", "hikaru", "nick", "buck"]
    
    func setButton(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
    }
    
    

}
