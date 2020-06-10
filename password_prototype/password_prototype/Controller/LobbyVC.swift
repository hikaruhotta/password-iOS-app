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
    
    @IBOutlet weak var numberOfRoundsLabel: UILabel!
    
    @IBOutlet weak var roundsSlider: UISlider!
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let currentValue = Int(roundsSlider.value)
        numberOfRoundsLabel.text = "Number of Rounds: \(currentValue)"
    }
    
    @IBAction func addBotButtonPressed(_ sender: Any) {
    }
    
    @IBAction func unwindToSplashPressed(_ sender: Any) {
        print("DATA IS NOW RESET")
        LOCAL = LocalData()
    }

    var databaseHandle: DatabaseHandle? // the listener
    
    lazy var functions = Functions.functions()
    
    @IBOutlet weak var startGameButton: UIButton!
    
    @IBOutlet weak var lobbyCodeLabel: UILabel!
    
    @IBOutlet weak var playerListTableView: UITableView!
    
    
    // Configures actions for start game when start game button is pressed
    @IBAction func startGamePressed(_ sender: Any) {
        print(Int(roundsSlider.value))
        functions.httpsCallable("startGame").call(["settings": ["numRounds": Int(roundsSlider.value), "wordBankSize": 6]]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let message = error.localizedDescription
                    print(message)
                }
                print("error in create lobby request")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerListTableView.delegate = self
        playerListTableView.dataSource = self
        lobbyCodeLabel.text = LOCAL.lobby?.lobbyCode
        startGameButton.isHidden = !LOCAL.isHost
        roundsSlider.isHidden = !LOCAL.isHost
        numberOfRoundsLabel.isHidden = !LOCAL.isHost
        
        startGameButton.alpha = 0.5
        startGameButton.isEnabled = false
        
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
            if LOCAL.users.count > 1 {
                self.startGameButton.alpha = 1.0
                self.startGameButton.isEnabled = true
            }
        }
        
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
