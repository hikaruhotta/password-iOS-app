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
    
    // will be self expanding list of words
    var wordBank: [String] = [
        "alarm",
        "scorch",
        "leap",
        "paltry",
        "refer",
        "cloth",
        "allow",
        "garrulous",
        "dizzy",
        "treatment",
        "important",
        "salty",
        "noiseless",
        "suggest",
        "paste"
    ]
    
    var randomWords: [String] = [
        "frame",
        "furtive",
        "harm",
        "derive",
        "degree",
        "act",
        "creature",
        "shoot",
        "nation",
        "bear",
        "fall",
        "relax",
        "retain",
        "saddle",
        "subscribe"
    ]
    
    var wordBankIndex = 3
    
    var randomWordsIndex = 0
    
    @IBOutlet weak var wordsTableView: UITableView!
    
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    
    
    // outlets to word buttons
    @IBOutlet weak var randomButton: GradientButton!
    
    @IBOutlet weak var wordButton1: GradientButton!
    
    @IBOutlet weak var wordButton2: GradientButton!
    
    @IBOutlet weak var wordButton3: GradientButton!
    
    @IBOutlet weak var buttonView: UIView!
    
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
        
        wordBank.shuffle()
        let word1 = wordBank[0]
        let word2 = wordBank[1]
        let word3 = wordBank[2]
        
        wordButton1.setTitle(word1, for: .normal)
        wordButton2.setTitle(word2, for: .normal)
        wordButton3.setTitle(word3, for: .normal)

        
        wordsTableView.estimatedRowHeight = 100
        wordsTableView.rowHeight = UITableView.automaticDimension
        
        wordsTableView.dataSource = self
        wordsTableView.delegate = self
        

    }
    
    
    @IBAction func segmentControlToggled(_ sender: Any) {
        switch mySegmentedControl.selectedSegmentIndex
        {
        case 0:
            buttonView.isHidden = false
            let frame = CGRect(x: 0, y: 176, width: self.view.frame.width - 10, height: 495)
            wordsTableView.frame = frame
            wordsTableView.scrollToBottom()
            //show popular view
        case 1:
            buttonView.isHidden = true
            let frame = CGRect(x: 0, y: 176, width: self.view.frame.width - 10, height: 600)
            wordsTableView.frame = frame
            wordsTableView.scrollToBottom()
            //show history view
        default:
            break;
        }
        self.wordsTableView.reloadData()
    }
    
    @IBAction func wordButtonPressed(_ sender: Any) {
        guard sender is UIButton else {
            return
        }
        var playedWord = ""
        switch (sender as AnyObject).tag {
        case 4:
            if randomWordsIndex == randomWords.count {
                print("beta version out of random words")
                return
            }
            playedWord = randomWords[randomWordsIndex]
            randomWordsIndex += 1
        default:
            if wordBankIndex == wordBank.count {
                print("beta version out of word bank words")
                return
            }
            playedWord = (sender as AnyObject).title(for: .normal) ?? String()
            (sender as AnyObject).setTitle(wordBank[wordBankIndex], for: .normal)
            wordBankIndex += 1
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let word = Word(word: playedWord, user: LOCAL.user, timeStamp : dateFormatter.string(from: Date()), score : 0)
        let myUpdates = ["/lobbies/\(LOCAL.lobby!.lobbyId)/wordList/word\(words.count)" : word.constructDict()]
        self.ref?.updateChildValues(myUpdates)
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
