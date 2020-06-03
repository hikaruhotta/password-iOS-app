//
//  JoinGameLobbyViewController.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/2/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFunctions

class LobbyVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: DatabaseReference?
    
    var gameStatusHandle: UInt!
    
    var playerAddedHandle: UInt!
    
    
    
    var databaseHandle: DatabaseHandle? // the listener
    lazy var functions = Functions.functions()
    
    @IBOutlet weak var startGameButton: UIButton!
    
    @IBOutlet weak var lobbyCodeLabel: UILabel!
    
    @IBOutlet weak var playerListTableView: UITableView!
    
    
    @IBAction func startGamePressed(_ sender: Any) {
        //LOCAL.user.userID = retrieveUserID(users: LOCAL.users, user: LOCAL.user)
        functions.httpsCallable("startGame").call() { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let message = error.localizedDescription
                    print(message)
                }
                print("error in create lobby request")
            }
            //self.performSegue(withIdentifier: "segueStartGame", sender: nil)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        print("**** DELETE")
//        users = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerListTableView.delegate = self
        playerListTableView.dataSource = self
        lobbyCodeLabel.text = LOCAL.lobby?.lobbyCode
        
        startGameButton.isHidden = !LOCAL.isHost
        
        // Set the firebase reference
        ref = Database.database().reference()
        // call this when it loads
        playerAddedHandle = ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public/players").observe(.childAdded) { (snapshot) in
            if let userDetails = snapshot.value as? [String: Any] {
                let newUser = User(dictionary: userDetails, userID: snapshot.key)
                LOCAL.users.append(newUser)
            }
            self.playerListTableView.reloadData()
            self.playerListTableView.scrollToBottom()
        }
        // cancel it when close
        
        
        // Listen to chages in game status -> segue to game screen VC
        gameStatusHandle = ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/public").observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value as? String {
                if snap == "SUBMISSION" {
                    self.performSegue(withIdentifier: "segueStartGame", sender: nil)
                    self.ref?.removeObserver(withHandle: self.gameStatusHandle)
                    self.ref?.removeObserver(withHandle: self.playerAddedHandle)
                }
            }

        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LOCAL.users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NameListCell") as! NameListCell
        cell.setUser(user: LOCAL.users[indexPath.row])
//        cell.changeName(name: sampleData[indexPath.row])
//        cell.modifyIcon(name: sampleData[indexPath.row])
        return cell
    }
    
    func retrieveUserID(users: [User], user: User) -> String {
        for u in users {
            if u.displayName == user.displayName && u.emojiNumber == user.emojiNumber && u.colorNumber == user.colorNumber {
                return u.userID
            }
        }
        return ""
    }
    
}


