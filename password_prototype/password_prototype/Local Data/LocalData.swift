//
//  LocalData.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/5/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import Foundation
import UIKit



class LocalData {
    
//    var icons = [
//        UIImage(named: "bear.png"), UIImage(named: "frog.png"), UIImage(named: "hippo.png"), UIImage(named: "lion.png"), UIImage(named: "panda.png"), UIImage(named: "zebra.png"), UIImage(named: "buck.png"), UIImage(named: "nick.png"), UIImage(named: "philip.png"), UIImage(named: "hikaru.png")]

    var imageNames = ["bear.png", "frog.png", "buck.png", "nick.png", "hikaru.png", "philip.png"]

    var colors = [UIColor.gray.cgColor, UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.yellow.cgColor, UIColor.green.cgColor, UIColor.blue.cgColor, UIColor.purple.cgColor]
    
    var emojis = ["💃🏻", "🦁", "🤓", "🌲", "🐮", "🧨", "🎱", "🍔", "🐶", "🍺", "🍕"]
    
    
    var lobby: Lobby?
    
    var codeToTry: String?
    
    var user = User()
    
//    var userName: String = "Anonymous"
//    var emojiNumber: Int = 0
//    var colorNumber: Int = 0
    
    func randomizeIcon() {
        self.user.emojiNumber = Int.random(in: 0..<emojis.count)
        self.user.colorNumber = Int.random(in: 0..<colors.count)
    }
    
}

var LOCAL = LocalData()

