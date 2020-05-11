//
//  SubmittedWordCell.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/4/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

class SubmittedWordCell: UITableViewCell {

    @IBOutlet weak var userIcon: UserSmallIconButton!
    
    @IBOutlet weak var wordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateWord(word: String) {
        wordLabel.text = word
    }
    
    
    func modifyIcon(user: User) {
        userIcon.setUserIcon(user: user)
    }

}
