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
        static let showDirectionLine: Bool = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupUserDefaults()
        setupUI()
    }
    
    // Set up User Defaults if they have no values
    class func setupUserDefaults() {
        let defaults = UserDefaults.standard
        
        if defaults.value(forKey: Settings.gliderRatio) == nil {
            defaults.set("20", forKey: Settings.gliderRatio)
        }
        if defaults.value(forKey: Settings.safetyAltitude) == nil {
            defaults.set(200, forKey: Settings.safetyAltitude)
        }
        if defaults.value(forKey: Settings.gliderID) == nil {
            defaults.set("D-1234", forKey: Settings.gliderID)
        }
        if defaults.value(forKey: Settings.mapRegionInMeters) == nil {
            defaults.set("15000", forKey: Settings.mapRegionInMeters)
        }
    }
    
    // Read User Defaults and display them on screen
    func setupUI(){
        gliderRatioTextField.text! = defaults.value(forKey: Settings.gliderRatio) as? String ?? "20"
        safetyAltitudeTextField.text! = (defaults.value(forKey: Settings.safetyAltitude) as! Double).description
        gliderIDTextfield.text! = defaults.value(forKey: Settings.gliderID) as? String ?? "D-1234"
        mapRegionInMetersTextField.text! = defaults.value(forKey: Settings.mapRegionInMeters) as? String ?? "15000"
    }
    
    // Return to Map View Button
    @IBAction func exitSettings(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Direction Line Switch
    @IBAction func showDirectionLineSwitch(_ sender: Any) {
    }
    
    // Save Button - Save Settings and dismiss Keyboard
    @IBAction func SaveButtonTapped(_ sender: Buttons) {
        saveSettings()
        self.view.endEditing(true)
    }
    
    //Save Settings to User Defaults
    func saveSettings(){
        // aus textField kommt immer ein String raus
        // -> string in double konvertieren!
        let safetyAltitudeString = safetyAltitudeTextField.text!
        let safetyAltitudeDouble = (safetyAltitudeString as NSString).doubleValue
        
        defaults.set(gliderRatioTextField.text!, forKey: Settings.gliderRatio);
        defaults.set(safetyAltitudeDouble, forKey: Settings.safetyAltitude);
        defaults.set(gliderIDTextfield.text!, forKey: Settings.gliderID);
        defaults.set(mapRegionInMetersTextField.text!, forKey: Settings.mapRegionInMeters);

// MARK: Output
        
//        // Output all Data
//        print("Glider Ratio set to: \(defaults.value(forKey: Settings.gliderRatio)!)")
//        print("Safety Altitude set to: \(defaults.value(forKey: Settings.safetyAltitude)!)")
//        print("Glider ID set to: \(defaults.value(forKey: Settings.gliderID)!)")
//        print("Map Region set to: \(defaults.value(forKey: Settings.mapRegionInMeters)!)")
    }
}
