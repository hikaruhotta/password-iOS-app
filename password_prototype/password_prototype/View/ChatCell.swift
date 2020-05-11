//
//  ChatCell.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/7/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    
    @IBOutlet weak var userIcon: UserSmallIconButton!
    
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
        
        
    func modifyIcon(user: User) {
        userIcon.setUserIcon(user: user)
    }

}
