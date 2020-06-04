//
//  RoundedButton.swift
//  ask_1.0
//
//  Created by PhilipRonnie Quiambao on 2/8/20.
//  Copyright © 2020 PhilipRonnie Quiambao. All rights reserved.
//

import UIKit


@IBDesignable
class RoundedButton: UIButton {
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet{
            setButton(cornerRadius: cornerRadius)
        }
    }
    
    func setButton(cornerRadius: CGFloat){
        if cornerRadius == 0 {
            layer.cornerRadius = layer.frame.height / 2
        }
        layer.cornerRadius = cornerRadius
    }
    
}
