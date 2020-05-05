//
//  SubmittedWordCell.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/4/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

class SubmittedWordCell: UITableViewCell {

    @IBOutlet weak var userIcon: UserIconImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateWord(name: String) {
//        nameLabel.text = name
    }
    
    var icons = [UIImage(named: "bear.png"), UIImage(named: "frog.png"), UIImage(named: "hippo.png"), UIImage(named: "lion.png"), UIImage(named: "panda.png"), UIImage(named: "zebra.png") ]
    
    var colors = [UIColor.gray.cgColor, UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.yellow.cgColor, UIColor.green.cgColor, UIColor.blue.cgColor, UIColor.purple.cgColor]
    
    func modifyIcon(name: String) {
        userIcon.image = icons[Int.random(in: 0..<icons.count)]
        userIcon.layer.cornerRadius = (userIcon.frame.size.width ) / 2
        userIcon.clipsToBounds = true
        userIcon.layer.borderWidth = 3.0
        userIcon.layer.borderColor = colors[Int.random(in: 0..<colors.count)]
    }

}
