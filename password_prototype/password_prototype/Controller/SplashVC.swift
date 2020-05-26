//
//  ViewController.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/2/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit
import FirebaseFunctions


class SplashVC: UIViewController, UITextFieldDelegate {
    @IBAction func unwindToSplashVC(_ sender: UIStoryboardSegue) {
    }
    @IBOutlet weak var usernameTextField: UITextField!
    
    lazy var functions = Functions.functions()
    
    @IBAction func inputUserName(_ sender: Any) {
        let field = sender as? UITextField
        LOCAL.user.displayName = field?.text ?? "Anonymous"
    }
    @IBAction func joinGamePressed(_ sender: Any) {
        LOCAL.users = []
        self.performSegue(withIdentifier: "segueToLobbyCodeVC", sender: nil)
    }
    
    @IBAction func newGameButtonPressed(_ sender: Any) {
        // REGISTER USER
//        print("EMOJI: \(LOCAL.user.emojiNumber)")
//        print("COLOR: \(LOCAL.user.colorNumber)")
        
        LOCAL.users = []
        
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
        usernameTextField.delegate = self
        
        
        //         listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }

    @IBOutlet weak var profileButton: ProfileButton!
    
    @IBAction func changeProfile(_ sender: Any) {
        LOCAL.randomizeIcon()
        profileButton.reloadButton()
    }
    
    // UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    func hideKeyboard() {
        usernameTextField.resignFirstResponder()
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        print("keyboard will show: \(notification.name.rawValue)")
                guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }

        if (notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification) {
            view.frame.origin.y = -keyboardRect.height / 2
        } else {
            view.frame.origin.y = 0
        }
    }
    
    // Stop listen for keyboard hide/show events
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
}

