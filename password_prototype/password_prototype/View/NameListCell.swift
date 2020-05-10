//
//  NameListCell.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/2/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

class NameListCell: UITableViewCell {

    @IBInspectable
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var userIcon: UserSmallIconButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setUser(user: User) {
        nameLabel.text = user.username
        userIcon.setUserIcon(user: user)
    }

}
