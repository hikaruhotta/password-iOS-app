//
//  CreateNewGameViewController.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/4/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

class NewGameVC: UIViewController, UITableViewDelegate,
    UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return db.lobbies[0].players.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NameListCell") as! NameListCell
        //cell.changeName(name: db.lobbies[0])
        cell.changeName(name: db.lobbies[0].players[indexPath.row])
        cell.modifyIcon(name: db.lobbies[0].players[indexPath.row])
        return cell
    }
    
    //var sampleData = ["philip", "hikaru", "nick", "buck"]
    
    
    @IBOutlet weak var playerListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerListTableView.delegate = self
        playerListTableView.dataSource = self
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
