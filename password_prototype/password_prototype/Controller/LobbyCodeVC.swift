//
//  EnterRoomCodeViewController.swift
//  password_prototype
//
//  Created by Hikaru Hotta on 5/3/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit
import FirebaseFunctions

class LobbyCodeVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var inputTextField: UITextField!
    
    lazy var functions = Functions.functions()
    
    @IBOutlet weak var enterLobbyButton: WelcomeScreenButton!
    
    @IBAction func enterLobbyButtonPressed(_ sender: UIButton) {
        self.enterLobbyButton.isEnabled = false
        print(inputTextField.text ?? "nothing" )
        // REGISTER USER
        
        functions.httpsCallable("joinLobby").call(["lobbyCode" : "\(inputTextField.text!)",
            "player": ["displayName" : "\(LOCAL.user.displayName)",
                "colorNumber" : LOCAL.user.colorNumber,  "emojiNumber" : LOCAL.user.emojiNumber]]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    //              let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    print(message)
                    //              let details = error.userInfo[FunctionsErrorDetailsKey]
                }
                print("error in create lobby request")
                // MAKE "ALERT" HERE TO SHOW LOBBY DOES NOT EXIST
                let alert = UIAlertController(title: "Lobby \(self.inputTextField.text ?? "nothing") Does Not Exist", message: "Please double check the Lobby code.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.inputTextField.text = ""
                
                self.enterLobbyButton.isEnabled = true
                return
            }
            if var resultDictionary = result?.data as? [String: String] {
                resultDictionary["lobbyCode"] = self.inputTextField.text!
                LOCAL.lobby = Lobby(dictionary: resultDictionary)
                self.enterLobbyButton.isEnabled = true
                LOCAL.isHost = false
                self.performSegue(withIdentifier: "segueToLobby", sender: nil)
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextField.delegate = self
        // Do any additional setup after loading the view.
        
        //         listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    func hideKeyboard() {
        inputTextField.resignFirstResponder()
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        print("keyboard will show: \(notification.name.rawValue)")
    }
    
    // Stop listen for keyboard hide/show events
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

}
