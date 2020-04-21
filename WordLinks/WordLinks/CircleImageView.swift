//
//  CircleImageView.swift
//  WordLinks
//
//  Created by PhilipRonnie Quiambao on 4/21/20.
//  Copyright © 2020 spice-girls-cs194. All rights reserved.
//

import UIKit

@IBDesignable
class CircleImageView: UIImageView {

    @IBInspectable
    var diameter : CGFloat = 0 {
        didSet {
            makeCircular(diameter: diameter)
        }
    }

    func makeCircular(diameter: CGFloat) {
        layer.cornerRadius = diameter / 2
    }


}
