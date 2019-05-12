//
//  UserSettingsViewController.swift
//  Glider Tool
//
//  Created by sonic on 08.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class UserSettingsViewController: UIViewController {

    @IBOutlet weak var gliderRatioTextField: TextFields!
    @IBOutlet weak var safetyAltitudeTextField: TextFields!
    @IBOutlet weak var gliderIDTextfield: TextFields!
    @IBOutlet weak var mapRegionInMetersTextField: TextFields!
    
    let defaults = UserDefaults.standard
    
    struct Settings {
        static let gliderRatio = "gliderRatio"
        static let safetyAltitude = "safetyAltitude"
        static let gliderID = "gliderID"
        static let mapRegionInMeters = "mapRegionInMeters"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForSavedSettings()
    }
    
    // Check for saved Settings and display them on Screen. If nil use these defaults.
    func checkForSavedSettings(){
        let gliderRatio = defaults.value(forKey: Settings.gliderRatio) as? String ?? "30"
        gliderRatioTextField.text = gliderRatio
        
        let safetyAltitude = defaults.value(forKey: Settings.safetyAltitude) as? String ?? "200"
        safetyAltitudeTextField.text! = safetyAltitude
        
        let gliderID = defaults.value(forKey: Settings.gliderID) as? String ?? "D-1234"
        gliderIDTextfield.text = gliderID
       
        let mapRegionInMeters = defaults.value(forKey: Settings.mapRegionInMeters) as? String ?? "10000"
        mapRegionInMetersTextField.text = mapRegionInMeters
    }
    
    // Return to Map View Button
    @IBAction func exitSettings(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Save Button - Save Settings and dismiss Keyboard
    @IBAction func SaveButtonTapped(_ sender: Buttons) {
        saveSettings()
        self.view.endEditing(true)
    }
    
    //Save Settings to User Defaults
    func saveSettings(){
        defaults.set(gliderRatioTextField.text!, forKey: Settings.gliderRatio);
        defaults.set(safetyAltitudeTextField.text!, forKey: Settings.safetyAltitude);
        defaults.set(gliderIDTextfield.text!, forKey: Settings.gliderID);
        defaults.set(mapRegionInMetersTextField.text!, forKey: Settings.mapRegionInMeters);
    }
}


