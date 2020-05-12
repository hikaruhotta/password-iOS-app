//
//  ViewController.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/2/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit
import FirebaseFunctions


class SplashVC: UIViewController {
    @IBAction func unwindToSplashVC(_ sender: UIStoryboardSegue) {
    }
    
    lazy var functions = Functions.functions()
    
    @IBAction func inputUserName(_ sender: Any) {
        let field = sender as? UITextField
        LOCAL.user.username = field?.text ?? "Anonymous"
    }
    
    @IBAction func newGameButtonPressed(_ sender: Any) {
        // REGISTER USER
//        print("EMOJI: \(LOCAL.user.emojiNumber)")
//        print("COLOR: \(LOCAL.user.colorNumber)")
        functions.httpsCallable("createLobby").call(["user": ["username" : "\(LOCAL.user.username)",
            "emojiNumber" : "\(LOCAL.user.emojiNumber)", "colorNumber" : "\(LOCAL.user.colorNumber)", "score" : "0"] ]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    //              let code = FunctionsErrorCode(rawValue: error.code)
                    //              let message = error.localizedDescription
                    //              let details = error.userInfo[FunctionsErrorDetailsKey]
                }
                print("error in create lobby request")
                return
            }
            if let resultDictionary = result?.data as? [String: String] {
                LOCAL.lobby = Lobby(dictionary: resultDictionary)
                print("calling segue")
                self.performSegue(withIdentifier: "segueNewGame", sender: nil)
                print(LOCAL.lobby ?? "nothing to see here")
            }
        }
    }
    
    
    @IBAction func createLobbyTest(_ sender: Any) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBOutlet weak var profileButton: ProfileButton!
    
    @IBAction func changeProfile(_ sender: Any) {
        LOCAL.randomizeIcon()
        profileButton.reloadButton()
    }
    
}

