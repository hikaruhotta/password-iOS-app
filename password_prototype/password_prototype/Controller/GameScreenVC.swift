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
    
    @IBAction func unwindToGameScreen(_ sender: UIStoryboardSegue) {
    }
    
//    @IBAction func unwindButtonPressed(_ sender: Any) {
//        print("DATA IS NOW RESET")
//        LOCAL = LocalData()
//    }
    
    // Create the reference to the database
    var ref: DatabaseReference?
    
    var databaseHandle: DatabaseHandle? // the listener
    lazy var functions = Functions.functions()
    
    var words: [Word] = []
    var boolArray = [Bool]()
    var messages: [Message] = []
    
    var startingWord = "password"
    
    
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
    
    @IBAction func informationButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "information2", sender: nil)
    }
    
    var numberOfVotes = 0
    
    @IBAction func resetWordBank(_ sender: Any) {
        switch(mySegmentedControl.selectedSegmentIndex) {
        case 0:
            self.disableWordBank()
            functions.httpsCallable("requestNewWords").call() { (result, error) in
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let message = error.localizedDescription
                        print(message)
                    }
                } else {
                    print("reseting word bank")
                    
                }
            }
        default:
            // clears text field in chat
            inputField.text = ""
        }
    }
    
    
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "SeedWordCell") as! SeedWordCell
                cell.setStartingWord(word: startingWord)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SubmittedWordCell") as! SubmittedWordCell
                // if last cell call showVotingButtons
                if indexPath.row == words.count, !LOCAL.hasVoted {
                    cell.showVotingButtons(numberOfVotes: self.numberOfVotes)
                } else {
                    cell.hideVotingButtons()
                }
                cell.modifyIcon(user: words[indexPath.row - 1].player!, row: indexPath.row)
                cell.updateWord(word: words[indexPath.row - 1].word ?? "")
                print("*** reload data called and printing numberOfVotes: \(numberOfVotes)")
                cell.updateProgressBar(numberOfVotes: numberOfVotes)
                
                if indexPath.row < words.count {
                    cell.hideProgressBar()
                } else {
                    cell.showProgressBar()
                }
                
                if indexPath.row > words.count - LOCAL.users.count {
                    cell.showScoreLabel()
                } else {
                    cell.hideScoreLabel()
                }
                
                return cell
            }
        // CHAT
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
            print(messages)
            let userID = messages[indexPath.row].userID!
            let user = retrieveUserFromID(userID: userID, users: LOCAL.users)
            cell.modifyIcon(user: user)
            cell.updateChat(message: messages[indexPath.row].message ?? "")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    var counter: Int = 1
    var chatCounter: Int = 1
    
    
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
    
    // Stop listening for keyboard hide/show events
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // Configure Actions for Submit Button
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
                        let alert = UIAlertController(title: "Invalid Word Submission", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        self.inputField.text = ""
                        print(message)
                    }
                }
            }
            inputField.text = ""
            hideKeyboard()
        case 1: // chat toggle
            if inputField.text == nil  || inputField.text?.count == 0 {
                return
            }
            if inputField.text?.count ?? 0 > 100 {
                let alert = UIAlertController(title: "Message contains \( inputField.text?.count ?? 101) characters.", message: "Please limit your message to 100 characters.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                let textPrefix = inputField.text!.prefix(100)
                print("userID is \(LOCAL.user.userID)")
                let myUpdates = ["/lobbies/\(LOCAL.lobby!.lobbyId)/public/chat/message\(messages.count)" : ["userID": LOCAL.user.userID, "message": textPrefix, "timeStamp": dateFormatter.string(from: Date())]]
                self.ref?.updateChildValues(myUpdates)
                inputField.text = ""
            }
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
        
        // Set the firebase reference
        ref = Database.database().reference()
        
        let id = retrieveUserID(users: LOCAL.users, user: LOCAL.user)
        LOCAL.user.userID = id
        
        // observe wordBank creation
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/private/\(LOCAL.user.userID)").observe(.childAdded) { (snapshot) in
            if let wordBank = snapshot.value as? [String] {
                LOCAL.user.targetWords = wordBank
                self.setWordBankText()
            }
        }
        
        // observe changes in the wordbank when it is reset
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/private/\(LOCAL.user.userID)").observe(.childChanged) { (snapshot) in
            if let wordBank = snapshot.value as? [String] {
                LOCAL.user.targetWords = wordBank
                self.setWordBankText()
                print("wordbank reset")
            }
        }
        
        // observe words played
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public/turns").observe(.childAdded) { (snapshot) in
            if let wordDetails = snapshot.value as? [String: Any] {
                let newWord = Word(dictionary: wordDetails)
                self.words.append(newWord)
            }
            self.words.sort { (left, right) -> Bool in
                left.created! < right.created!
            }
            self.wordsTableView.reloadData()
            self.wordsTableView.scrollToBottom()
        }
        
        // WHAT IS THE DIFFERENCE WITH THE ABOVE FUNCTION???
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public/turns").observe(.childChanged) { (snapshot) in
            if let wordDetails = snapshot.value as? [String: Any] {
                let newWord = Word(dictionary: wordDetails)
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
        
        // Observe changes to user score
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public/players").observe(.childChanged) { (snapshot) in
            if let updatedUser = snapshot.value as? [String: Any] {
                let userID = snapshot.key
                let index = retrieveUserIndex(users: LOCAL.users, userID: userID)
                let score = updatedUser["score"]
                LOCAL.users[index].score = score as! Int
            }
        }
        
        // Observe changes in the number of votes
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public").observe(.childChanged) { (snapshot) in
            if snapshot.key == "votesTallied" {
                self.numberOfVotes = snapshot.value as! Int
                if self.numberOfVotes == LOCAL.users.count - 1 {
                    self.numberOfVotes = 0
                }
            } else {
                self.numberOfVotes = 0
            }
            self.wordsTableView.reloadData()
            self.wordsTableView.scrollToBottom()
        }
        
        // for observing message child added
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public/chat").observe(.childAdded) { (snapshot) in
            print("*** CHAT ADDED ***")
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
        
        // Observe changes of game status to "SUBMISSION"
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public").observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value as? String {
                if snap == "SUBMISSION" {
                    print("==== Game Status Changed ===")
                    LOCAL.hasVoted = false
                }
                
                if snap == "DONE" {
                    print("==== Game Status DONE ===")
                    LOCAL.gameDone = true
                    self.performSegue(withIdentifier: "segueToStandings", sender: nil)
                }
            }
        }
        
        // Observe changes of game status to "SUBMISSION"
//        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public").observe { (snapshot) in
//            //if snapshot.key == "startWord" {
//                if let snap = snapshot.value as? [String: Any] {
//                    print("**** snap is below ****")
//                    print(snap)
//                }
//            //}
//
//
//        }
        
            
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public").child("startWord").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.startingWord = snapshot.value! as! String
        }) { (error) in
            print(error.localizedDescription)
        }

        
        wordsTableView.dataSource = self
        wordsTableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        wordsTableView.estimatedRowHeight = 100
        wordsTableView.rowHeight = UITableView.automaticDimension
        
    }
    
    // Toggled between game and chat screens
    @IBAction func segmentControlToggled(_ sender: Any) {
        switch mySegmentedControl.selectedSegmentIndex
        {
        case 0:
            buttonView.isHidden = false
            let frame = CGRect(x: 0, y: 176, width: self.view.frame.width - 10, height: 495)
            wordsTableView.frame = frame
            wordsTableView.scrollToBottom()
        case 1:
            buttonView.isHidden = true
            let frame = CGRect(x: 0, y: 176, width: self.view.frame.width - 10, height: 600)
            wordsTableView.frame = frame
            wordsTableView.scrollToBottom()
        default:
            break;
        }
        self.wordsTableView.reloadData()
    }
    
    
    // Configure actions when a button in the word bank is pressed
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
    
    // Function to set the word bank button text
    func setWordBankText() {
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
        self.wordButton1.isEnabled = true
        self.wordButton2.isEnabled = true
        self.wordButton3.isEnabled = true
        self.wordButton4.isEnabled = true
        self.wordButton5.isEnabled = true
        self.wordButton6.isEnabled = true
    }
    
    func disableWordBank() {
        self.wordButton1.isEnabled = false
        self.wordButton2.isEnabled = false
        self.wordButton3.isEnabled = false
        self.wordButton4.isEnabled = false
        self.wordButton5.isEnabled = false
        self.wordButton6.isEnabled = false
    }
    
    func enableWordBank() {
        self.wordButton1.isEnabled = true
        self.wordButton2.isEnabled = true
        self.wordButton3.isEnabled = true
        self.wordButton4.isEnabled = true
        self.wordButton5.isEnabled = true
        self.wordButton6.isEnabled = true
    }
    
}

extension UITableView {
    
    // Scrolls a TableView to the bottom
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
    
    // Scrolls a TableView to the bottom
    func scrollToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
}

// Retrieves userID from User object
func retrieveUserID(users: [User], user: User) -> String {
    for u in users {
        if u.displayName == user.displayName && u.emojiNumber == user.emojiNumber && u.colorNumber == user.colorNumber {
            return u.userID
        }
    }
    return ""
}

// Retrieves index of user in list given a User object
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

func retrieveUserFromID(userID: String, users: [User]) -> User {
    for u in users {
        if u.userID == userID {
            return u
        }
    }
    return User()
}
