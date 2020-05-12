//
//  JoinGameLobbyViewController.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/2/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit
import FirebaseDatabase

class LobbyVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: DatabaseReference?
    
    
    var users = [User]()
    
    @IBOutlet weak var lobbyCodeLabel: UILabel!
    
    @IBOutlet weak var playerListTableView: UITableView!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
//        print("**** DELETE")
//        users = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerListTableView.delegate = self
        playerListTableView.dataSource = self
        lobbyCodeLabel.text = LOCAL.lobby?.lobbyCode
        
        
        // Set the firebase reference
        ref = Database.database().reference()
        // for observing child added
        ref?.child("/lobbies/\(LOCAL.lobby!.lobbyId)/users").observe(.childAdded) { (snapshot) in
            if let userDetails = snapshot.value as? [String: String] {
//                print("***** USER DETAILS BELOW *****")
//                print(userDetails)
                let newUser = User(dictionary: userDetails)
                print("EMOJI: \(newUser.emojiNumber)")
                print("COLOR: \(newUser.colorNumber)")
                
                self.users.append(newUser)
            }
            self.playerListTableView.reloadData()
            self.playerListTableView.scrollToBottom()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NameListCell") as! NameListCell
        cell.setUser(user: users[indexPath.row])
//        cell.changeName(name: sampleData[indexPath.row])
//        cell.modifyIcon(name: sampleData[indexPath.row])
        return cell
    }
    
}


