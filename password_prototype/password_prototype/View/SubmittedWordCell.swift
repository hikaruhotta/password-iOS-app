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
    
    @IBOutlet weak var wordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateWord(word: String) {
        wordLabel.text = word
    }
    
    
    
    func modifyIcon(name: String) {
        userIcon.image = LOCAL.icons[Int.random(in: 0..<LOCAL.icons.count)]
        userIcon.layer.cornerRadius = (userIcon.frame.size.width ) / 2
        userIcon.clipsToBounds = true
        userIcon.layer.borderWidth = 3.0
        userIcon.layer.borderColor = LOCAL.colors[Int.random(in: 0..<LOCAL.colors.count)]
    }

}
