//
//  GameScreenVC.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 5/4/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFunctions

class GameScreenVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Create the reference to the database
    var ref: DatabaseReference?
    
    var databaseHandle: DatabaseHandle? // the listener
    lazy var functions = Functions.functions()
    
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
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var wordButton1: GradientButton!
    @IBOutlet weak var wordButton2: GradientButton!
    @IBOutlet weak var wordButton3: GradientButton!
    @IBOutlet weak var wordButton4: GradientButton!
    @IBOutlet weak var wordButton5: GradientButton!
    @IBOutlet weak var wordButton6: GradientButton!
    
    
    
    @IBOutlet weak var inputMenuView: UIView!
    @IBOutlet weak var inputField: UITextField!

    var numberOfVotes = 0
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(mySegmentedControl.selectedSegmentIndex) {
        case 0:
            return words.count + 1
        case 1:
            return messages.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(mySegmentedControl.selectedSegmentIndex) {
            
            // GAME
        case 0:
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SubmittedWordCell") as! SubmittedWordCell
                cell.modifyIcon(user: User(), row: indexPath.row)
                //cell.markAsSeed() // hide icon
                cell.updateWord(word: "password")
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SubmittedWordCell") as! SubmittedWordCell
                // if last cell call showVotingButtons
                if indexPath.row == words.count {
                    cell.showVotingButtons(numberOfVotes: numberOfVotes)
                } else {
                    cell.hideVotingButtons()
                }
                cell.modifyIcon(user: words[indexPath.row - 1].player!, row: indexPath.row)
                cell.updateWord(word: words[indexPath.row - 1].word ?? "")
                return cell
            }
            
            // CHAT
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
            cell.modifyIcon(user: messages[indexPath.row].user!)
            cell.updateChat(message: messages[indexPath.row].message ?? "")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    var counter: Int = 1
    var chatCounter: Int = 1

    
    
    // KEYBOARD
    // ========
    
    // **NOT MINE** Calls this function when the tap is recognized.
//    @objc func dismissKeyboard() {
//        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        view.endEditing(true)
//    }
    
    // UITextFieldDelegate Methods
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        hideKeyboard()
//        return true
//    }
    
    func hideKeyboard() {
        inputField.resignFirstResponder()
    }
    
    // UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        print("keyboard will show: \(notification.name.rawValue)")
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }

        if (notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification) {
            print( inputMenuView.frame.origin.y)
            inputMenuView.frame.origin.y = view.frame.size.height - keyboardRect.height - inputMenuView.frame.size.height 
            wordsTableView.frame.size.height = 494 - 180
            wordsTableView.scrollToBottom()
        } else {
            inputMenuView.frame.origin.y = 661.0
            wordsTableView.frame.size.height = 494
            wordsTableView.reloadData()
        }
    }
    
    // Stop listen for keyboard hide/show events
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @IBAction func submitButton(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        switch(mySegmentedControl.selectedSegmentIndex) {
        case 0: // game toggle
            if inputField.text == nil  || inputField.text?.count == 0 {
                return
            }
            functions.httpsCallable("submitWord").call(["word": inputField.text]) { (result, error) in
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let message = error.localizedDescription
                        print(message)
                    }
                    print("error in create lobby request")
                }
            }
            
            
            
//            let word = Word(word: inputField.text!, user: LOCAL.user,
//                          timeStamp : dateFormatter.string(from: Date()),
//                          score : "0")
//
//            let myUpdates = ["/lobbies/\(LOCAL.lobby!.lobbyId)/wordList/word\(words.count)" : word.constructDict()]
//            self.ref?.updateChildValues(myUpdates)
            inputField.text = ""
            hideKeyboard()
        case 1: // chat toggle
//            if inputField.text == nil  || inputField.text?.count == 0 {
//                return
//            }
//            let message = Message(user: LOCAL.user, message: inputField.text!, timeStamp: dateFormatter.string(from: Date()))
//            let myUpdates = ["/lobbies/\(LOCAL.lobby!.lobbyId)/chat/message\(messages.count)" : message.constructDict()]
//            self.ref?.updateChildValues(myUpdates)
//            inputField.text = ""
            return
        default:
            return
        }
    }
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inputField.delegate = self
        
//         listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//        
//        // **NOT MINE** for tapping outside of keyboard
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        //Uncomment the line below if you want the tap not to interfere and cancel other interactions.
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
        
        
        
        // Set the firebase reference
        ref = Database.database().reference()
        
        let id = retrieveUserID(users: LOCAL.users, user: LOCAL.user)
        LOCAL.user.userID = id
        // observe wordBank creation
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/private/\(LOCAL.user.userID)").observe(.childAdded) { (snapshot) in
            if let wordBank = snapshot.value as? [String] {
                LOCAL.user.targetWords = wordBank
                self.wordButton1.setTitle(LOCAL.user.targetWords![0], for: .normal)
                self.wordButton2.setTitle(LOCAL.user.targetWords![1], for: .normal)
                self.wordButton3.setTitle(LOCAL.user.targetWords![2], for: .normal)
                self.wordButton4.setTitle(LOCAL.user.targetWords![3], for: .normal)
                self.wordButton5.setTitle(LOCAL.user.targetWords![4], for: .normal)
                self.wordButton6.setTitle(LOCAL.user.targetWords![5], for: .normal)
                self.wordButton1.titleLabel?.adjustsFontSizeToFitWidth = true
                self.wordButton2.titleLabel?.adjustsFontSizeToFitWidth = true
                self.wordButton3.titleLabel?.adjustsFontSizeToFitWidth = true
                self.wordButton4.titleLabel?.adjustsFontSizeToFitWidth = true
                self.wordButton5.titleLabel?.adjustsFontSizeToFitWidth = true
                self.wordButton6.titleLabel?.adjustsFontSizeToFitWidth = true
            }
        }

        
        
        // for observing child added
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public/turns").observe(.childAdded) { (snapshot) in
            if let wordDetails = snapshot.value as? [String: Any] {
                let newWord = Word(dictionary: wordDetails)
                //print(newWord)
                self.words.append(newWord)
//                if newWord.word == nil {
//
//                    self.words.append(newWord)
//                }

            }
            self.words.sort { (left, right) -> Bool in
                left.created! < right.created!
            }
            self.wordsTableView.reloadData()
            self.wordsTableView.scrollToBottom()
        }
        
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public/turns").observe(.childChanged) { (snapshot) in
            
            if let wordDetails = snapshot.value as? [String: Any] {
                let newWord = Word(dictionary: wordDetails)
                // replace/update the word
                
                if let index = self.words.firstIndex(matching: newWord) {
                    self.words.remove(at: index)
                    self.words.append(newWord)
                }

            }
            self.words.sort { (left, right) -> Bool in
                left.created! < right.created!
            }
            self.wordsTableView.reloadData()
            self.wordsTableView.scrollToBottom()
        }
        
        // listen to player
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public/players").observe(.childChanged) { (snapshot) in
            if let updatedUser = snapshot.value as? [String: Any] {
                let userID = snapshot.key
                let index = retrieveUserIndex(users: LOCAL.users, userID: userID)
                let score = updatedUser["score"]
                LOCAL.users[index].score = score as! Int
            }
        }
        
        // listen to number of votes
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/internal").observe(.childAdded) { (snapshot) in
            print("*** votes changed ***")
            print("snapshot.key: \(snapshot.key)")
            if let snapshotValue = snapshot.value as? [String: Any] {
                //print("*** votes incremented ***")
                print(snapshotValue)
                //self.numberOfVotes = votes.count
            } else {
                print("*** votes to zero ***")
                self.numberOfVotes = 0
            }
            print("*** reload table ***")
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
    
    override func viewWillAppear(_ animated: Bool) {
        wordsTableView.estimatedRowHeight = 100
        wordsTableView.rowHeight = UITableView.automaticDimension
        
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
        let pressedWord = (sender as AnyObject).title(for: .normal) ?? String()
        functions.httpsCallable("submitWord").call(["word": pressedWord]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let message = error.localizedDescription
                    print(message)
                }
            } else{
                print("submitted: \(pressedWord)")
                (sender as AnyObject).setTitleColor(UIColor.gray, for: .disabled)
                (sender as! UIButton).isEnabled = false
            }
            
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

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

func retrieveUserID(users: [User], user: User) -> String {
    for u in users {
        if u.displayName == user.displayName && u.emojiNumber == user.emojiNumber && u.colorNumber == user.colorNumber {
            return u.userID
        }
    }
    return ""
}

func retrieveUserIndex(users: [User], userID: String) -> Int {
    var counter = 0
    for u in users {
        if u.userID == userID  {
            return counter
        }
        counter += 1
    }
    return 0
}




