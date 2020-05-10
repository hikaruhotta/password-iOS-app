//
//  EnterRoomCodeViewController.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/3/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit
import FirebaseFunctions

class LobbyCodeVC: UIViewController {

    
    @IBOutlet weak var inputTextField: UITextField!
    
    lazy var functions = Functions.functions()
    
    @IBAction func enterLobbyButtonPressed(_ sender: Any) {
        print(inputTextField.text ?? "nothing" )
        // REGISTER USER
        functions.httpsCallable("joinLobby").call(["lobbyCode" : "\(inputTextField.text!)",
            "user": ["username" : "\(LOCAL.userName)", "emojiNumber" : "\(LOCAL.emojiNumber)",
                "colorNumber" : "\(LOCAL.colorNumber)", "score" : "0"]]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    //              let code = FunctionsErrorCode(rawValue: error.code)
                    //              let message = error.localizedDescription
                    //              let details = error.userInfo[FunctionsErrorDetailsKey]
                }
                print("error in create lobby request")
                // TODO: - MAKE ALERT HERE TO SHOW LOBBY DOES NOT EXIST
                return
            }
            if var resultDictionary = result?.data as? [String: String] {
//                print(resultDictionary)
                resultDictionary["lobbyCode"] = self.inputTextField.text!
                LOCAL.lobby = Lobby(dictionary: resultDictionary)
                self.performSegue(withIdentifier: "segueToLobby", sender: nil)
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
