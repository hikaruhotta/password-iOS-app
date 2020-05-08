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
            return 3
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(mySegmentedControl.selectedSegmentIndex) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmittedWordCell") as! SubmittedWordCell
            cell.modifyIcon(name: indexPath.row % 2 == 0 ? "philip" : "lion")
            cell.updateWord(word: words[indexPath.row].word ?? "")
            print(indexPath.row)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
            let messageID = "message" + String(indexPath.row + 1)
            print(messageID)
            ref?.child("/sampleLobby/chat/" + messageID).observe(DataEventType.value, with: { (snapshot) in
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                let user = postDict["user"]! as! String
                let contents = postDict["content"]! as! String
                if user == "user1" {
                    cell.modifyIcon(name: "philip")
                } else {
                    cell.modifyIcon(name: "lion")
                }
                cell.updateChat(chat: contents)
            })
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
        switch(mySegmentedControl.selectedSegmentIndex) {
        case 0: // game toggle
            if inputField.text == nil  || inputField.text?.count == 0 {
                return
            }
            //how to post word
            let post1 = [ "word" : inputField.text!,
                          "user" : "user1",
                          "order" : self.counter as Any,
                          "score" : 0,
                          "vetoCount" : [String]() ] as [String : Any]
            let myUpdates = ["/sampleLobby/wordList/word\(self.counter)" : post1]
            self.ref?.updateChildValues(myUpdates)
            // update counter
            self.counter += 1
            ref?.updateChildValues(["/sampleLobby/counter" : ["value" : counter]])
            inputField.text = ""
        case 1: // chat toggle
            if inputField.text == nil  || inputField.text?.count == 0 {
                return
            }
            //how to post word
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date / server String
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let post1 = ["content" : inputField.text!,
                         "user" : "user1",
                         "timeStamp" : formatter.string(from: Date())
                ] as [String : Any]
            let myUpdates = ["/sampleLobby/chat/message\(self.chatCounter)" : post1]
            self.ref?.updateChildValues(myUpdates)
            // update counter
            self.chatCounter += 1
            ref?.updateChildValues(["/sampleLobby/chatCounter" : ["value" : chatCounter]])
            inputField.text = ""
        default:
            return
        }
    }
    
    override func viewDidLoad() {
        

        super.viewDidLoad()
        // Set the firebase reference
        ref = Database.database().reference()



        // create counter
        let initiateCounter = ["value" : counter] as [String: Int]
        let uploadCounter = ["/sampleLobby/counter" : initiateCounter]
        ref?.updateChildValues(uploadCounter)
        print("***** initiate counter")
        
        // create chat counter
        let initiateChatCounter = ["value" : chatCounter] as [String: Int]
        let uploadChatCounter = ["/sampleLobby/chatCounter" : initiateChatCounter]
        ref?.updateChildValues(uploadChatCounter)
        print("***** initiate chat counter")
        
        
        // observe counter
        ref?.child("/sampleLobby/counter").observe(.value) { (snapshot) in
            if let possibileValue = snapshot.value as? [String : Int] {
                self.counter = possibileValue["value"]!
            }
            print("***** observe counter: \(self.counter)")
        }
        
        // observe chat counter
        ref?.child("/sampleLobby/chatCounter").observe(.value) { (snapshot) in
            if let possibleValue = snapshot.value as? [String : Int] {
                self.chatCounter = possibleValue["value"]!
            }
            print("***** observe chat counter: \(self.chatCounter)")
        }
        
        // observe messages
        ref?.child("/sampleLobby/chat/message1").observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            print("***** observe message: \(postDict["content"]!)")
        })
        
        
        
        //how to post words
        let post1 = [ "word" : "apple",
                      "user" : "user1",
                      "order" : self.counter as Any,
                      "score" : 0,
                      "vetoCount" : [String]() ] as [String : Any]
        var myUpdates = ["/sampleLobby/wordList/word1" : post1]
        self.ref?.updateChildValues(myUpdates)
        // update counter
        self.counter += 1
        ref?.updateChildValues(["/sampleLobby/counter" : ["value" : counter]])


        let post2 = [ "word" : "elves",
                      "user" : "user2",
                      "order" : self.counter as Any,
                      "score" : 0,
                      "vetoCount" : [String]() ] as [String : Any]
        myUpdates = ["/sampleLobby/wordList/word2" : post2]
        self.ref?.updateChildValues(myUpdates)
        // update counter
        self.counter += 1
        ref?.updateChildValues(["/sampleLobby/counter" : ["value" : counter]])

        
        
        let post3 = [ "word" : "Selma",
                      "user" : "user3",
                      "order" : self.counter as Any,
                      "score" : 0,
                      "vetoCount" : [String]() ] as [String : Any]
        myUpdates = ["/sampleLobby/wordList/word3" : post3]
        self.ref?.updateChildValues(myUpdates)
        // update counter
        self.counter += 1
        ref?.updateChildValues(["/sampleLobby/counter" : ["value" : counter]])
        
        
        // for observing child added
        ref?.child("/sampleLobby/wordList").observe(.childAdded) { (snapshot) in
            if let wordDetails = snapshot.value as? [String: Any] {
                let newWord = Word(dictionary: wordDetails)
                self.words.append(newWord)
            }
            
            self.words.sort { (left, right) -> Bool in
                left.order! < right.order!
            }
            
            self.wordsTableView.reloadData()
            self.wordsTableView.scrollToBottom()
        }
        
        // how to post messages
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let postMessage1 = ["content" : "What's up dude!",
                     "user" : "user1",
                     "timeStamp" : formatter.string(from: Date())
            ] as [String : Any]
        myUpdates = ["/sampleLobby/chat/message\(self.chatCounter)" : postMessage1]
        self.ref?.updateChildValues(myUpdates)
        // update counter
        self.chatCounter += 1
        ref?.updateChildValues(["/sampleLobby/chatCounter" : ["value" : chatCounter]])
        
        let postMessage2 = ["content" : "Nothing much you?",
                     "user" : "user2",
                     "timeStamp" : formatter.string(from: Date())
            ] as [String : Any]
        myUpdates = ["/sampleLobby/chat/message\(self.chatCounter)" : postMessage2]
        self.ref?.updateChildValues(myUpdates)
        // update counter
        self.chatCounter += 1
        ref?.updateChildValues(["/sampleLobby/chatCounter" : ["value" : chatCounter]])
        
        let postMessage3 = ["content" : "I'm not buying that word you played dude :(",
                     "user" : "user1",
                     "timeStamp" : formatter.string(from: Date())
            ] as [String : Any]
        myUpdates = ["/sampleLobby/chat/message\(self.chatCounter)" : postMessage3]
        self.ref?.updateChildValues(myUpdates)
        // update counter
        self.chatCounter += 1
        ref?.updateChildValues(["/sampleLobby/chatCounter" : ["value" : chatCounter]])
        
        // for observing message child added
        //ref?.child("/sampleLobby/chat").observe(.childAdded) { (snapshot) in
          //  if let messageDetails = snapshot.value as? [String: Any] {
            //    let newMessage = Message(dictionary: messageDetails)
              //  self.messages.append(newMessage)
            //}
            
            //self.messages.sort { (left, right) -> Bool in
              //  formatter(from: left.timeStamp!) < formatter(right.timeStamp!)
            //}
            
            //self.wordsTableView.reloadData()
            //self.wordsTableView.scrollToBottom()
        //}
        
        wordsTableView.dataSource = self
        wordsTableView.delegate = self
    }
    
    
    @IBAction func segmentControlToggled(_ sender: Any) {
        self.wordsTableView.reloadData()
    }
    
    
    
    
}


/*
 PULLING ONCE
         ref?.child("sampleWordsList").observeSingleEvent(of: .value, with: { (snapshot) in
             if let wordList = snapshot.value as? NSDictionary {
                 print(wordList)
                 for word in wordList {
                     if let wordDetails = word.value as? [String: String] {
                         print(wordDetails)
                         self.words.append(Word(dictionary: wordDetails))
                     }
                 }
             }
             self.wordsTableView.reloadData()
         })
 */

/*
 SETTING ONE VALUE
             self.ref?.child("lobby1WordList").child("1").setValue(["word": "air"])
 */

extension UITableView {

    func scrollToBottom(){

        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func scrollToTop() {

        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}
