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
        LOCAL.user.displayName = field?.text ?? "Anonymous"
    }
    
    @IBAction func newGameButtonPressed(_ sender: Any) {
        // REGISTER USER
//        print("EMOJI: \(LOCAL.user.emojiNumber)")
//        print("COLOR: \(LOCAL.user.colorNumber)")
        functions.httpsCallable("createLobby").call(["player": ["displayName" : "\(LOCAL.user.displayName)",
            "colorNumber" : LOCAL.user.colorNumber, "emojiNumber" : LOCAL.user.emojiNumber] ]) { (result, error) in
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
                LOCAL.isHost = true
                self.performSegue(withIdentifier: "segueNewGame", sender: nil)
                print("*** Lobby Details ***")
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

