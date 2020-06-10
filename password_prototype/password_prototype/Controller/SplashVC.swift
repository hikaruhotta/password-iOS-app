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
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var profileButton: ProfileButton!
    lazy var functions = Functions.functions()
    
    @IBAction func unwindToSplashVC(_ sender: UIStoryboardSegue) {
    }
    
    @IBAction func inputUserName(_ sender: Any) {
        let field = sender as? UITextField
        LOCAL.user.displayName = field?.text ?? "Anonymous"
    }
    
    @IBAction func joinGamePressed(_ sender: Any) {
        LOCAL.users = []
        self.performSegue(withIdentifier: "segueToLobbyCodeVC", sender: nil)
    }
    
    @IBAction func newGameButtonPressed(_ sender: Any) {
        LOCAL.users = []
        functions.httpsCallable("createLobby").call(["player": ["displayName" : "\(LOCAL.user.displayName)",
            "colorNumber" : LOCAL.user.colorNumber, "emojiNumber" : LOCAL.user.emojiNumber] ]) { (result, error) in
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let message = error.localizedDescription
                        print(message)
                    }
                    print("error in create lobby request")
                    return
                }
                if let resultDictionary = result?.data as? [String: String] {
                    LOCAL.lobby = Lobby(dictionary: resultDictionary)
                    LOCAL.isHost = true
                    self.performSegue(withIdentifier: "segueNewGame", sender: nil)
                }
        }
    }
    
    @IBAction func createLobbyTest(_ sender: Any) {
    }
    
    @IBAction func changeProfile(_ sender: Any) {
        LOCAL.randomizeIcon()
        profileButton.reloadButton()
    }
    
    
    @IBAction func informationButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "information1", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        usernameTextField.delegate = self
        LOCAL.randomizeIcon()
        profileButton.reloadButton()
        
        //         listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    // Stop listening for keyboard hide/show events
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
}
