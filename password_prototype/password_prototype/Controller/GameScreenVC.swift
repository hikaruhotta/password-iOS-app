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
    
    @IBOutlet weak var wordsTableView: UITableView!
    
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(mySegmentedControl.selectedSegmentIndex) {
        case 0:
            return words.count
        case 1:
            return 1
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
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
            //cell.modifyIcon(name: indexPath.row % 2 == 0 ? "philip" : "lion")
            cell.updateChat(chat: "hello!")
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "SubmittedWordCell") as! SubmittedWordCell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    var counter: Int = 1
    
    @IBOutlet weak var inputField: UITextField!
    
    @IBAction func submitButton(_ sender: Any) {
        if inputField.text == nil  || inputField.text?.count == 0 {
            return
        }
        //how to post
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
        
        
        // observe counter
        ref?.child("/sampleLobby/counter").observe(.value) { (snapshot) in
            if let possibileValue = snapshot.value as? [String : Int] {
                self.counter = possibileValue["value"]!
            }
            print("***** observe counter: \(self.counter)")
        }
        
        
        //how to post
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
