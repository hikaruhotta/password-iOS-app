//
//  ChatCell.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/7/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    
    @IBOutlet weak var userIcon: UserIconImageView!
    @IBOutlet weak var chatMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateChat(message: String) {
            chatMessage.text = message
    }
        
        
    func modifyIcon(name: String) {
        userIcon.image = UIImage(named: name + ".png")
        userIcon.layer.cornerRadius = (userIcon.frame.size.width ) / 2
        userIcon.clipsToBounds = true
        userIcon.layer.borderWidth = 3.0
        userIcon.layer.borderColor = name == "philip" ? UIColor.red.cgColor : UIColor.blue.cgColor
    //        userIcon.layer.borderColor = LOCAL.colors[Int.random(in: 0..<LOCAL.colors.count)]
        }

}
