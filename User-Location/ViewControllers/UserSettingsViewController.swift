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
    @IBOutlet weak var mapRegionInMetersTextField: TextFields!
    
    let defaults = UserDefaults.standard
    
    struct Keys {
        
        static let gliderRatio = "30"
        static let safetyAltitude = "200"
        static let gliderID = "gliderID"
        static let mapRegionInMeters = "10000"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForSavedSettings()
    }
    
    // Check for saved Settings and display it on Screen
    func checkForSavedSettings(){
        let gliderRatio = defaults.value(forKey: Keys.gliderRatio) as? String ?? ""
        gliderRatioTextFied.text = gliderRatio
        
        let safetyAltitude = defaults.value(forKey: Keys.safetyAltitude) as? String ?? ""
        safetyAltitudeTextField.text! = safetyAltitude
        
        let gliderID = defaults.value(forKey: Keys.gliderID) as? String ?? ""
        gliderIDTextfield.text = gliderID
       
        let mapRegionInMeters = defaults.value(forKey: Keys.mapRegionInMeters) as? String ?? ""
        mapRegionInMetersTextField.text = mapRegionInMeters
    }
    
    // Return to Map View
    @IBAction func exitUserSettings(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // Save Settings to User Defaults
    @IBAction func SaveButtonTapped(_ sender: Buttons) {
        saveSettings()
    }

    func saveSettings(){
        defaults.set(gliderRatioTextFied.text!, forKey: Keys.gliderRatio);
        defaults.set(safetyAltitudeTextField.text!, forKey: Keys.safetyAltitude);
        defaults.set(gliderIDTextfield.text!, forKey: Keys.gliderID);
        defaults.set(mapRegionInMetersTextField.text!, forKey: Keys.mapRegionInMeters);
    }
}
