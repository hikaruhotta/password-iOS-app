//
//  GameScreenVC.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/4/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit
import FirebaseDatabase

class GameScreenVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Create the reference to the database
    var ref: DatabaseReference?
    
    var databaseHandle: DatabaseHandle? // the listener
    
    var words: [Word] = []
    
    var messages: [Message] = []
    
    @IBOutlet weak var wordsTableView: UITableView!
    
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(mySegmentedControl.selectedSegmentIndex) {
        case 0:
            return words.count
        case 1:
            return messages.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(mySegmentedControl.selectedSegmentIndex) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmittedWordCell") as! SubmittedWordCell
            cell.modifyIcon(user: words[indexPath.row].user!)
            cell.updateWord(word: words[indexPath.row].word ?? "")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
            cell.modifyIcon(user: messages[indexPath.row].user!)
            cell.updateChat(message: messages[indexPath.row].message ?? "")
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "SubmittedWordCell") as! SubmittedWordCell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    var counter: Int = 1
    var chatCounter: Int = 1
    
    @IBOutlet weak var inputField: UITextField!
    
    @IBAction func submitButton(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        switch(mySegmentedControl.selectedSegmentIndex) {
        case 0: // game toggle
            if inputField.text == nil  || inputField.text?.count == 0 {
                return
            }
            let word = Word(word: inputField.text!, user: LOCAL.user,
                          timeStamp : dateFormatter.string(from: Date()),
                          score : 0)
            
            let myUpdates = ["/lobbies/\(LOCAL.lobby!.lobbyId)/wordList/word\(words.count)" : word.constructDict()]
            self.ref?.updateChildValues(myUpdates)
            inputField.text = ""
        case 1: // chat toggle
            if inputField.text == nil  || inputField.text?.count == 0 {
                return
            }
            let message = Message(user: LOCAL.user, message: inputField.text!, timeStamp: dateFormatter.string(from: Date()))
            let myUpdates = ["/lobbies/\(LOCAL.lobby!.lobbyId)/chat/message\(messages.count)" : message.constructDict()]
            self.ref?.updateChildValues(myUpdates)
            inputField.text = ""
            return
        default:
            return
        }
    }
    
    override func viewDidLoad() {
        

        super.viewDidLoad()
        // Set the firebase reference
        ref = Database.database().reference()

        // for observing child added
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/wordList").observe(.childAdded) { (snapshot) in
            if let wordDetails = snapshot.value as? [String: Any] {
                let newWord = Word(dictionary: wordDetails)
                self.words.append(newWord)
            }
            self.words.sort { (left, right) -> Bool in
                left.timeStamp! < right.timeStamp!
            }
            self.wordsTableView.reloadData()
            self.wordsTableView.scrollToBottom()
        }
        
        // for observing message child added
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/chat").observe(.childAdded) { (snapshot) in
            if let messageDetails = snapshot.value as? [String: Any] {
                let newMessage = Message(dictionary: messageDetails)
                self.messages.append(newMessage)
            }
            self.messages.sort { (left, right) -> Bool in
                left.timeStamp! < right.timeStamp!
            }
            self.wordsTableView.reloadData()
            self.wordsTableView.scrollToBottom()
        }
        
        wordsTableView.dataSource = self
        wordsTableView.delegate = self
    }
    
    
    @IBAction func segmentControlToggled(_ sender: Any) {
        self.wordsTableView.reloadData()
    }
    
}

extension UITableView {

    func scrollToBottom(){
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if indexPath.row >= 0, indexPath.section >= 0 {
                self.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    func scrollToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}
