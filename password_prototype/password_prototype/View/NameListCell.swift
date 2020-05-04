//
//  NameListCell.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/2/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

class NameListCell: UITableViewCell {

    @IBInspectable @IBOutlet weak var nameLabel: UILabel!
    @IBInspectable @IBOutlet weak var userIcon: UserIconImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func changeName(name: String) {
        nameLabel.text = name
    }
    
    func modifyIcon(name: String) {
        userIcon.image=UIImage(named: name + ".png")
        userIcon.layer.cornerRadius = (userIcon.frame.size.width ) / 2
        userIcon.clipsToBounds = true
        userIcon.layer.borderWidth = 3.0
        userIcon.layer.borderColor = UIColor.gray.cgColor
    }

}
