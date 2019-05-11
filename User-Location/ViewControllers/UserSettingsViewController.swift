//
//  UserSettingsViewController.swift
//  Glider Tool
//
//  Created by sonic on 08.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class UserSettingsViewController: UIViewController {
    
 
    @IBOutlet weak var gliderRatioTextFied: TextFields!
    @IBOutlet weak var safetyAltitudeTextField: TextFields!
    @IBOutlet weak var gliderIDTextfield: TextFields!
    

    let defaults = UserDefaults.standard
    
    struct Keys {
        static let gliderID = "gliderID"
        static let safetyAltitude: Double = 200
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        checkForSavedSettings()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func exitUserSettings(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func SaveButtonTapped(_ sender: SaveButton) {
        saveSettings()
    }

    func saveSettings(){
        defaults.set(gliderIDTextfield.text!, forKey: Keys.gliderID);
        //defaults.set (safetyAltitudeTextField.text!, forKey: Keys.safetyAltitude as? String?)
    }
    
    func checkForSavedSettings(){
        let gliderIDTextField = defaults.value(forKey: Keys.gliderID) as? String ?? ""
        gliderIDTextfield.text = gliderIDTextField
    }
    
}
