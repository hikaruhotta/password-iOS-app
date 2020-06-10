//
//  SeedWordCell.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 6/9/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

class SeedWordCell: UITableViewCell {

    @IBOutlet weak var startingWordLabel: UILabel!
    
    func setStartingWord(word: String) {
        startingWordLabel.text = word
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
