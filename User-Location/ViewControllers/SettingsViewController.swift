//
//  SettingsViewController.swift
//  Glider Tool
//
//  Created by sonic on 27.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit
    
    class SettingsViewController: UIViewController {
        
        @IBOutlet weak var gliderRatioTextField: TextFields!
        @IBOutlet weak var safetyAltitudeTextField: TextFields!
        @IBOutlet weak var gliderIDTextField: TextFields!
        @IBOutlet weak var showDirectionLineSwitch: UISwitch!
        @IBOutlet weak var showTrackingRouteSwitch: UISwitch!
        
        // ToDo: das ist irgendwie doppelt drin
        let defaults = UserDefaults.standard
        
        struct Settings {
            static let gliderRatio = "gliderRatio"
            static let safetyAltitude = "safetyAltitude"
            static let gliderID = "gliderID"
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            
            // Direction Line Switch Setup
            if (defaults.object(forKey: "ShowDirectionToDestinationAirportSwitchState") != nil) {
                showDirectionLineSwitch.isOn = defaults.bool(forKey: "ShowDirectionToDestinationAirportSwitchState")
            }
            
            // Tracking Route Switch Setup
            if (defaults.object(forKey: "ShowTrackingRouteSwitchState") != nil) {
                showTrackingRouteSwitch.isOn = defaults.bool(forKey: "ShowTrackingRouteSwitchState")
            }
        }
        
        // Set up User Defaults if they have no values
        class func setupUserDefaults() {
            let defaults = UserDefaults.standard
            
            if defaults.value(forKey: Settings.gliderRatio) == nil {
                defaults.set(20, forKey: Settings.gliderRatio)
            }
            if defaults.value(forKey: Settings.safetyAltitude) == nil {
                defaults.set(200, forKey: Settings.safetyAltitude)
            }
            if defaults.value(forKey: Settings.gliderID) == nil {
                defaults.set("D-1234", forKey: Settings.gliderID)
            }
        }
        
        // Read User Defaults and display them on screen
        func setupUI(){
            gliderRatioTextField.text! = (defaults.value( forKey: Settings.gliderRatio) as! Double).description
            safetyAltitudeTextField.text! = (defaults.value(forKey: Settings.safetyAltitude) as! Double).description
            gliderIDTextField.text! = defaults.value(forKey: Settings.gliderID) as? String ?? "D-1234"
        }
        
        // Direction Line Switch
        @IBAction func showDirectionLineSwitch(_ sender: Any) {
            if showDirectionLineSwitch.isOn {
                defaults.set(true, forKey: "ShowDirectionToDestinationAirportSwitchState")
            } else {
                defaults.set(false, forKey: "ShowDirectionToDestinationAirportSwitchState")
            }
        }
        
        @IBAction func showTrackingRouteSwitch(_ sender: Any) {
            if showTrackingRouteSwitch.isOn {
                defaults.set(true, forKey: "ShowTrackingRouteSwitchState")
            } else {
                defaults.set(false, forKey: "ShowTrackingRouteSwitchState")
            }
        }
        
        @IBAction func SaveButtonTapped(_ sender: Buttons) {
            saveSettings()
            self.view.endEditing(true)
            }
        
        //Save Settings to User Defaults
        func saveSettings(){
            let gliderRatioString = gliderRatioTextField.text!
            let gliderRatioDouble = (gliderRatioString as NSString).doubleValue
            
            let safetyAltitudeString = safetyAltitudeTextField.text!
            let safetyAltitudeDouble = (safetyAltitudeString as NSString).doubleValue
            
            defaults.set(gliderRatioDouble, forKey: Settings.gliderRatio);
            defaults.set(safetyAltitudeDouble, forKey: Settings.safetyAltitude);
            defaults.set(gliderIDTextField.text!, forKey: Settings.gliderID);

            // MARK: - Output
            
            print("Settings saved")
            
            //        print("Glider Ratio set to: \(defaults.value(forKey: Settings.gliderRatio)!)")
            //        print("Safety Altitude set to: \(defaults.value(forKey: Settings.safetyAltitude)!)")
            //        print("Glider ID set to: \(defaults.value(forKey: Settings.gliderID)!)")
            //        print("Direction Line Switch: \(defaults.bool(forKey: "ShowDirectionToDestinationAirportSwitchState"))")
            //        print("Tracking Route Switch: \(defaults.bool(forKey: "ShowTrackingRouteSwitchState"))")
        }
}
