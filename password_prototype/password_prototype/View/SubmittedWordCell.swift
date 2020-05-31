//
//  SubmittedWordCell.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/4/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFunctions

class SubmittedWordCell: UITableViewCell {

    lazy var functions = Functions.functions()
    
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var challengeButton: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func acceptWord(_ sender: Any) {
        functions.httpsCallable("voteOnWord")
            .call(["challenge": false]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let message = error.localizedDescription
                    print(message)
                }
                print("error in voting request")
            }
                print("*** voted accept ***")
        }
    }

    @IBAction func challengeWord(_ sender: Any) {
        functions.httpsCallable("voteOnWord")
            .call(["challenge": true]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let message = error.localizedDescription
                    print(message)
                }
                print("error in voting request")
            }
                print("*** voted accept ***")
        }
    }
    
    @IBOutlet weak var userIcon: UserSmallIconButton!
    
    @IBOutlet weak var wordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateWord(word: String) {
        wordLabel.text = word
        
        if wordLabel.text?.count ?? 0 > 0 {
            acceptButton.alpha = 1
            acceptButton.isEnabled = true
            challengeButton.alpha = 1
            challengeButton.isEnabled = true
        } else {
            acceptButton.alpha = 0.3
            acceptButton.isEnabled = false
            challengeButton.alpha = 0.3
            challengeButton.isEnabled = false
            wordLabel.text = "..."
        }
        
    }
    
    func markAsSeed() {
        userIcon.isHidden = true
        nameLabel.isHidden = true
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func modifyIcon(user: User, row: Int) {
        userIcon.setUserIcon(user: user)
        nameLabel.text = user.displayName
        
        if row == 0 {
            userIcon.isHidden = true
            nameLabel.isHidden = true
            scoreLabel.isHidden = true
            hideVotingButtons()
        } else {
            userIcon.isHidden = false
            nameLabel.isHidden = false
            scoreLabel.isHidden = false
        }
        
        if user.displayName == LOCAL.user.displayName, user.colorNumber == LOCAL.user.colorNumber, user.emojiNumber == LOCAL.user.emojiNumber {
            hideVotingButtons()
            
        }
        let index = retrieveUserIndex(users: LOCAL.users, userID: user.userID)
        scoreLabel.text = String(LOCAL.users[index].score)
        
    }
    
    func showVotingButtons(){
        acceptButton.isHidden = false
        challengeButton.isHidden = false
    }
    
    func hideVotingButtons() {
        acceptButton.isHidden = true
        challengeButton.isHidden = true
    }
    
    func updateUserScore(user: User){
        scoreLabel.text = String(user.score)
    }
    

}
