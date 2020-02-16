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
    
    // Notification Observers
    var airportUpdateFailedNotification: NSObjectProtocol?
    
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
    
    // MARK: - Private Instance Methods
    // Read User Defaults and display them on screen
    private func setupUI() {

        // Glider Ratio
        let gliderRatio = UserDefaultsManager.getGliderRatio()
        let gliderRatioString = String(format: "%.f", gliderRatio)
        gliderRatioTextField.text! = gliderRatioString
        
        // Safety Altitude
        let safetyAltitude = UserDefaultsManager.getSafetyAltitude()
        let safetyAltitudeString = String(format: "%.f", safetyAltitude)
        safetyAltitudeTextField.text! = safetyAltitudeString
        
        // Glider ID
        let gliderID = UserDefaultsManager.getGliderID()
        gliderIDTextField.text! = gliderID
        
        // Landing Gear Warning Switch Setup
        let landingGearWarningSwitchState = UserDefaultsManager.getLandingGearWarningSwitch()
        landingGearWarningSwitch.isOn = landingGearWarningSwitchState
        
        // Tracking Route Switch Setup
        let showTrackingRouteSwitchState = UserDefaultsManager.getShowTrackingRouteSwitchKey()
        showTrackingRouteSwitch.isOn = showTrackingRouteSwitchState
    }
    
    // Save Settings to User Defaults
    private func saveSettings() {
        let gliderRatioString = gliderRatioTextField.text!
        let gliderRatioDouble = (gliderRatioString as NSString).doubleValue
        
        let safetyAltitudeString = safetyAltitudeTextField.text!
        let safetyAltitudeDouble = (safetyAltitudeString as NSString).doubleValue

        UserDefaultsManager.set(gliderRatio: gliderRatioDouble)
        UserDefaultsManager.set(safetyAltitude: safetyAltitudeDouble)
        UserDefaultsManager.set(gliderID: gliderIDTextField.text!)
    }
    
    // MARK: - Action Methods
    // Landing Gear Warning Switch
    @IBAction func landingGearWarningSwitch(_ sender: UISwitch) {
        UserDefaultsManager.set(landingGearWarningSwitch: landingGearWarningSwitch.isOn)
    }

    //Show Tracking Route Switch
    @IBAction func showTrackingRouteSwitch(_ sender: UISwitch) {
        UserDefaultsManager.set(showTrackingRouteSwitch: showTrackingRouteSwitch.isOn)
    }
    
    // Download updated Airport Database File from Server
    @IBAction func downloadAirportUpdates(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Download Airport Updates",
                                      message: "Do you want to download an updated Airport Database from Server?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .default,
                                      handler: { action in
                                        AirportDatabase.shared.downloadAirportsFromServer()
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
            return true
    }

    // Execute when Textfield did End Editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveSettings()
    }
    
}
