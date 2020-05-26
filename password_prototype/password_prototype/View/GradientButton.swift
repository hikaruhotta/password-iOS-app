//
//  GradientButton.swift
//  ask_1.0
//
//  Created by PhilipRonnie Quiambao on 2/8/20.
//  Copyright © 2020 PhilipRonnie Quiambao. All rights reserved.
//

import UIKit

@IBDesignable
class GradientButton: UIButton {
    let gradientLayer = CAGradientLayer()
    
    @IBInspectable
    var leftGradientColor: UIColor? {
        didSet {
            setGradient(leftGradientColor: leftGradientColor, rightGradientColor: rightGradientColor, cornerRadius: cornerRadius, shadowOpacity: shadowOpacity)
        }
    }
    
    @IBInspectable
    var rightGradientColor: UIColor? {
        didSet {
            setGradient(leftGradientColor: leftGradientColor, rightGradientColor: rightGradientColor, cornerRadius: cornerRadius, shadowOpacity: shadowOpacity)
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet{
            setGradient(leftGradientColor: leftGradientColor, rightGradientColor: rightGradientColor, cornerRadius: cornerRadius, shadowOpacity: shadowOpacity)
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float = 0 {
        didSet{
            setGradient(leftGradientColor: leftGradientColor, rightGradientColor: rightGradientColor, cornerRadius: cornerRadius, shadowOpacity: shadowOpacity)
        }
    }
    
    
    
    func setGradient(leftGradientColor: UIColor?, rightGradientColor: UIColor?, cornerRadius: CGFloat, shadowOpacity: Float) {
        if let leftGradientColor = leftGradientColor, let rightGradientColor = rightGradientColor {
            //set gradient
            gradientLayer.frame = bounds
            // custom
            gradientLayer.colors = [leftGradientColor.cgColor, rightGradientColor.cgColor]
            
            gradientLayer.cornerRadius = cornerRadius
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x:1.0, y: 0.5)
            // set shadow
            gradientLayer.shadowColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            gradientLayer.shadowRadius = 4 // set to 4?
            gradientLayer.shadowOpacity = shadowOpacity
            gradientLayer.shadowOffset = CGSize(width: 3, height: 3)
            layer.insertSublayer(gradientLayer, at: 0)

        } else {
            gradientLayer.removeFromSuperlayer()
        }
    }
}
