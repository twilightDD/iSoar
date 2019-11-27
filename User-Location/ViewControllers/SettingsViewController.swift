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
        static let gliderRatio = "gliderRatio"
        static let safetyAltitude = "safetyAltitude"
        static let gliderID = "gliderID"
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
        
        gliderIDTextField.delegate = self
        safetyAltitudeTextField.delegate = self
        gliderIDTextField.delegate = self
        
        // Landing Gear Warning Switch Setup
        if (defaults.object(forKey: "LandingGearWarningSwitchState") != nil) {
            landingGearWarningSwitch.isOn = defaults.bool(forKey: "LandingGearWarningSwitchState")
        }
        
        // Tracking Route Switch Setup
        if (defaults.object(forKey: "ShowTrackingRouteSwitchState") != nil) {
            showTrackingRouteSwitch.isOn = defaults.bool(forKey: "ShowTrackingRouteSwitchState")
        }
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
    
    // MARK: - Private Instance Methods
    // Read User Defaults and display them on screen
    func setupUI(){
        
        let gliderRatio = defaults.value( forKey: Settings.gliderRatio) as! Double
        let gliderRatioString = String(format: "%.f", gliderRatio)
        gliderRatioTextField.text! = gliderRatioString
        
        let safetyAltitude = defaults.value( forKey: Settings.safetyAltitude) as! Double
        let safetyAltitudeString = String(format: "%.f", safetyAltitude)
        safetyAltitudeTextField.text! = safetyAltitudeString
        
        let gliderID = defaults.value(forKey: Settings.gliderID) as? String ?? "D-1234"
        gliderIDTextField.text! = gliderID
        
    }
    
    // Save Settings to User Defaults
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
        print("Landing Gear Warning Switch is On: \(defaults.bool(forKey: "LandingGearWarningSwitchState"))")
        print("Tracking Route Switch is On: \(defaults.bool(forKey: "ShowTrackingRouteSwitchState"))")
    }
    
    // MARK: - Action Methods
    // Landing Gear Warning Switch
    @IBAction func landingGearWarningSwitch(_ sender: Any) {
        if landingGearWarningSwitch.isOn {
            defaults.set(true, forKey: "LandingGearWarningSwitchState")
        } else {
            defaults.set(false, forKey: "LandingGearWarningSwitchState")
        }
    }
    
    @IBAction func showTrackingRouteSwitch(_ sender: Any) {
        if showTrackingRouteSwitch.isOn {
            defaults.set(true, forKey: "ShowTrackingRouteSwitchState")
        } else {
            defaults.set(false, forKey: "ShowTrackingRouteSwitchState")
        }
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
    
    // ToDo: Temporary Socket Connect Button
    @IBAction func SocketConnect(_ sender: UIButton) {
        OGNSocketConnectionManager.shared.connectToServerSocket()
    }
    
    // Save User Defaults
    @IBAction func SaveButtonTapped(_ sender: Buttons) {
        saveSettings()
        self.view.endEditing(true)
    }
    
}

// MARK: - Extension - UITextFieldDelegate
extension SettingsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField)
        -> Bool {
            textField.resignFirstResponder()
            return true;
    }
    
}
