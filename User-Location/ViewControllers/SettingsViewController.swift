//
//  SettingsViewController.swift
//  Glider Tool
//
//  Created by sonic on 27.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

// MARK: SettingsViewController
class SettingsViewController: UIViewController {
    
    // MARK: Lets and Vats
    let defaults = UserDefaults.standard
    
    // Notification Observers
    var airportUpdateFailedNotification:NSObjectProtocol?
    
    struct Settings {
        static let GliderRatioKey = "gliderRatio"
        static let SafetyAltitudeKey = "safetyAltitude"
        static let GliderIDKey = "gliderID"
        static let LandingGearWarningSwitchKey = "landingGearWarningSwitch"
        static let ShowTrackingRouteSwitchKey = "showTrackingRouteSwitch"
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var gliderRatioTextField: TextFields!
    @IBOutlet weak var safetyAltitudeTextField: TextFields!
    @IBOutlet weak var gliderIDTextField: TextFields!
    @IBOutlet weak var landingGearWarningSwitch: UISwitch!
    @IBOutlet weak var showTrackingRouteSwitch: UISwitch!
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        gliderRatioTextField.delegate = self
        safetyAltitudeTextField.delegate = self
        gliderIDTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register observer for notfications
        airportUpdateFailedNotification = NotificationCenter.default
            .addObserver(forName: AirportDatabase.airportUpdateFailedNotificationName,
                         object: nil,
                         queue: OperationQueue.main) { [unowned self] (notification) in
                            
                            let alert = UIAlertController(title: "Download failed",
                                                          message: "It seems your Device has no active internet Connection.",
                                                          preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK",
                                                          style: .default,
                                                          handler: nil))
                            
                            self.present(alert, animated: true)
                            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let airportUpdateFailedNotification = airportUpdateFailedNotification {
            NotificationCenter.default.removeObserver(airportUpdateFailedNotification)
        }
    }
    
    // MARK: - Public Class Methods
    // Set up User Defaults if they have no values
    class func setupUserDefaults() {
        let defaults = UserDefaults.standard
        
        if defaults.value(forKey: Settings.GliderRatioKey) == nil {
            defaults.set(20, forKey: Settings.GliderRatioKey)
        }
        if defaults.value(forKey: Settings.SafetyAltitudeKey) == nil {
            defaults.set(200, forKey: Settings.SafetyAltitudeKey)
        }
        if defaults.value(forKey: Settings.GliderIDKey) == nil {
            defaults.set("D-1234", forKey: Settings.GliderIDKey)
        }
        if defaults.value(forKey: Settings.LandingGearWarningSwitchKey) == nil {
            defaults.set(true, forKey: Settings.LandingGearWarningSwitchKey)
        }
        if defaults.value(forKey: Settings.ShowTrackingRouteSwitchKey) == nil {
            defaults.set(true, forKey: Settings.ShowTrackingRouteSwitchKey)
        }
        
    }
    
    // MARK: - Private Instance Methods
    // Read User Defaults and display them on screen
    private func setupUI(){
        
        // Glider Ratio
        let gliderRatio = defaults.value( forKey: Settings.GliderRatioKey) as! Double
        let gliderRatioString = String(format: "%.f", gliderRatio)
        gliderRatioTextField.text! = gliderRatioString
        
        // Safety Altitude
        let safetyAltitude = defaults.value( forKey: Settings.SafetyAltitudeKey) as! Double
        let safetyAltitudeString = String(format: "%.f", safetyAltitude)
        safetyAltitudeTextField.text! = safetyAltitudeString
        
        // Glider ID
        let gliderID = defaults.value(forKey: Settings.GliderIDKey) as? String ?? "D-1234"
        gliderIDTextField.text! = gliderID
        
        // Landing Gear Warning Switch Setup
        let landingGearWarningSwitchState = defaults.value(forKey: Settings.LandingGearWarningSwitchKey) as! Bool
        landingGearWarningSwitch.isOn = landingGearWarningSwitchState
        
        // Tracking Route Switch Setup
        let showTrackingRouteSwitchState = defaults.value(forKey: Settings.ShowTrackingRouteSwitchKey) as! Bool
        showTrackingRouteSwitch.isOn = showTrackingRouteSwitchState
    }
    
    // Save Settings to User Defaults
    private func saveSettings(){
        let gliderRatioString = gliderRatioTextField.text!
        let gliderRatioDouble = (gliderRatioString as NSString).doubleValue
        
        let safetyAltitudeString = safetyAltitudeTextField.text!
        let safetyAltitudeDouble = (safetyAltitudeString as NSString).doubleValue
        
        defaults.set(gliderRatioDouble, forKey: Settings.GliderRatioKey);
        defaults.set(safetyAltitudeDouble, forKey: Settings.SafetyAltitudeKey);
        defaults.set(gliderIDTextField.text!, forKey: Settings.GliderIDKey);
        
        // MARK: - Output
        
        //                print("Settings saved")
        //                print("Glider Ratio set to: \(defaults.value(forKey: Settings.GliderRatioKey)!)")
        //                print("Safety Altitude set to: \(defaults.value(forKey: Settings.SafetyAltitudeKey)!)")
        //                print("Glider ID set to: \(defaults.value(forKey: Settings.GliderIDKey)!)")
        //                print("Landing Gear Warning Switch is On: \(defaults.bool(forKey: Settings.LandingGearWarningSwitchKey))")
        //                print("Show Tracking Route Switch is On: \(defaults.bool(forKey: Settings.ShowTrackingRouteSwitchKey))")
        
    }
    
    // MARK: - Action Methods
    // Landing Gear Warning Switch
    @IBAction func landingGearWarningSwitch(_ sender: UISwitch) {
        defaults.set(landingGearWarningSwitch.isOn, forKey: Settings.LandingGearWarningSwitchKey)
    }
    
    //Show Tracking Route Switch
    @IBAction func showTrackingRouteSwitch(_ sender: UISwitch) {
        defaults.set(showTrackingRouteSwitch.isOn, forKey: Settings.ShowTrackingRouteSwitchKey)
    }
    
    // Download updated Airport Database File from Server
    @IBAction func downloadAirportUpdates(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Download Airport Updates",
                                      message: "Do you want to download an updated Airport Database from Server?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .default,
                                      handler: { action in
                                        AirportDatabase.shared.downloadMapObjectsFromServer()
        }))
        alert.addAction(UIAlertAction(title: "No",
                                      style: .cancel,
                                      handler: nil))
        
        self.present(alert, animated: true)
        
    }
    
}

// MARK: - Extension - UITextFieldDelegate
extension SettingsViewController: UITextFieldDelegate {
    
    // Execute when Done Button is pressed
    func textFieldShouldReturn(_ textField: UITextField)
        -> Bool {
            textField.resignFirstResponder()
            return true;
    }
    
    // Execute when Textfield did End Editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveSettings()
    }
    
}
