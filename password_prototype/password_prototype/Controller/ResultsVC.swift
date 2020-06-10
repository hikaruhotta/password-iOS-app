//
//  ResultsVC.swift
//  password_prototype
//
//  Created by PhilipRonnie Quiambao on 6/8/20.
//  Copyright © 2020 Hikaru Hotta. All rights reserved.
//

import UIKit

class ResultsVC: UIViewController {

        @IBAction func unwindButtonPressed(_ sender: Any) {
            print("DATA IS NOW RESET")
            LOCAL = LocalData()
        }
    

    
    
    @IBOutlet weak var secondPlaceLabel: UILabel!
    @IBOutlet weak var secondPlaceBackground: GradientButton!
    @IBOutlet weak var thirdPlaceLabel: UILabel!
    @IBOutlet weak var thirdPlaceBackground: GradientButton!
    
    @IBOutlet weak var firstPlaceName: UILabel!
    
    @IBOutlet weak var secondPlaceName: UILabel!
    
    @IBOutlet weak var thirdPlaceName: UILabel!
    
    @IBOutlet weak var firstPlacePoints: UILabel!
    @IBOutlet weak var secondPlacePoints: UILabel!
    @IBOutlet weak var thirdPlacePoints: UILabel!
    
    @IBOutlet weak var firstPlaceIcon: UserSmallIconButton!
    @IBOutlet weak var secondPlaceIcon: UserSmallIconButton!
    @IBOutlet weak var thirdPlaceIcon: UserSmallIconButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupResults()
    }
    
    func setupResults() {
        if LOCAL.users.count < 2 {
            secondPlaceLabel.isHidden = true
            secondPlacePoints.isHidden = true
            secondPlaceName.isHidden = true
            secondPlaceIcon.isHidden = true
            secondPlaceBackground.isHidden = true
        } else {
            secondPlaceLabel.isHidden = false
            secondPlacePoints.isHidden = false
            secondPlaceName.isHidden = false
            secondPlaceIcon.isHidden = false
            secondPlaceBackground.isHidden = false
        }
        
        if LOCAL.users.count < 3 {
            thirdPlaceLabel.isHidden = true
            thirdPlacePoints.isHidden = true
            thirdPlaceName.isHidden = true
            thirdPlaceIcon.isHidden = true
            thirdPlaceBackground.isHidden = true
        } else {
            thirdPlaceLabel.isHidden = false
            thirdPlacePoints.isHidden = false
            thirdPlaceName.isHidden = false
            thirdPlaceIcon.isHidden = false
            thirdPlaceBackground.isHidden = false
        }
        
        let results = LOCAL.users.sorted(by: {$0.score > $1.score})
        
        // set 1st Place
        firstPlacePoints.text = String(results[0].score) + " Points"
        firstPlaceName.text = results[0].displayName
        // TODO: ICON
        firstPlaceIcon.setUserIcon(user: results[0])
        
        if results.count > 1 {
            secondPlacePoints.text = String(results[1].score) + " Points"
            secondPlaceName.text = results[1].displayName
            // TODO: ICON
            secondPlaceIcon.setUserIcon(user: results[1])
        }
        
        if results.count > 2 {
            thirdPlacePoints.text = String(results[2].score) + " Points"
            thirdPlaceName.text = results[2].displayName
            // TODO: ICON
            thirdPlaceIcon.setUserIcon(user: results[2])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupResults()
    }
}
