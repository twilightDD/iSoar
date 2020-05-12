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
    
    // MARK: IBOutlets
    @IBOutlet private weak var gliderRatioTextField: TextFields!
    @IBOutlet private weak var safetyAltitudeTextField: TextFields!
    @IBOutlet private weak var gliderIDTextField: TextFields!
    @IBOutlet private weak var ownFlarmIDTextField: TextFields!
    @IBOutlet private weak var buddyFlarmIDTextField: TextFields!
    @IBOutlet private weak var gearWarningSwitch: UISwitch!
    @IBOutlet private weak var showTrackingRouteSwitch: UISwitch!
    @IBOutlet private weak var flarmRadiusTextField: TextFields!
    @IBOutlet private weak var showAllNearbyGlidersSwitch: UISwitch!
    @IBOutlet private weak var showOnlyBuddySwitch: UISwitch!
    @IBOutlet private weak var collisionWarningSwitch: UISwitch!
    @IBOutlet private weak var downloadAirportUpdates: UIButton!
    @IBOutlet private weak var centeringHelpSwitch: UISwitch!

    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        gliderRatioTextField.delegate = self
        safetyAltitudeTextField.delegate = self
        gliderIDTextField.delegate = self
        ownFlarmIDTextField.delegate = self
        flarmRadiusTextField.delegate = self
        buddyFlarmIDTextField.delegate = self
    }
    
    // MARK: - Public Class Methods
    
    // MARK: - Private Instance Methods
    // Read User Defaults and display them on screen
    private func setupUI() {
        
        // Glider Ratio
        let gliderRatio = UserDefaultsManager.gliderRatio()
        let gliderRatioString = String(format: "%.f", gliderRatio)
        gliderRatioTextField.text = gliderRatioString
        
        // Safety Altitude
        let safetyAltitude = UserDefaultsManager.safetyAltitude()
        let safetyAltitudeString = String(format: "%.f", safetyAltitude)
        safetyAltitudeTextField.text = safetyAltitudeString
        
        // Glider ID
        let gliderID = UserDefaultsManager.gliderID()
        gliderIDTextField.text = gliderID
        
        // Own FlarmID
        let ownFlarmID = UserDefaultsManager.ownFlarmID()
        ownFlarmIDTextField.text = ownFlarmID
        
        // Gear Warning Switch Setup
        let gearWarningSwitchState = UserDefaultsManager.gearWarningState()
        gearWarningSwitch.isOn = gearWarningSwitchState
        
        // Tracking Route Switch Setup
        let showTrackingRouteSwitchState = UserDefaultsManager.showTrackingRouteState()
        showTrackingRouteSwitch.isOn = showTrackingRouteSwitchState
        
        // Show Flarm Buddy Switch Setup
        let showFlarmBuddySwitchState = UserDefaultsManager.showOnlyBuddySwitchState()
        showOnlyBuddySwitch.isOn = showFlarmBuddySwitchState
        
        // Buddy FlarmID
        let buddyFlarmID = UserDefaultsManager.buddyFlarmID()
        buddyFlarmIDTextField.text = buddyFlarmID
        
        // Show nearby Gliders Switch Setup
        let showNearbyGlidersSwitchState = UserDefaultsManager.showAllNearbyGlidersState()
        showAllNearbyGlidersSwitch.isOn = showNearbyGlidersSwitchState
        
        // Collision Warning Switch Setup
        let collsionWarningSwitchState = UserDefaultsManager.collisionWarningState()
        collisionWarningSwitch.isOn = collsionWarningSwitchState
        
        // Flarm Radius
        let flarmRadius = UserDefaultsManager.flarmRadius()
        let flarmRadiusString = String(format: "%.f", flarmRadius)
        flarmRadiusTextField.text = flarmRadiusString
        
        // Centering Help Switch Setup
        let centeringHelpSwitchState = UserDefaultsManager.centeringHelpState()
        centeringHelpSwitch.isOn = centeringHelpSwitchState
        
    }
    
    // Save Settings to User Defaults
    private func saveSettings() {
        let gliderRatioString = gliderRatioTextField.text!
        let gliderRatioDouble = (gliderRatioString as NSString).doubleValue
        UserDefaultsManager.set(gliderRatio: gliderRatioDouble)
        
        let safetyAltitudeString = safetyAltitudeTextField.text!
        let safetyAltitudeDouble = (safetyAltitudeString as NSString).doubleValue
        UserDefaultsManager.set(safetyAltitude: safetyAltitudeDouble)
        
        UserDefaultsManager.set(gliderID: gliderIDTextField.text!)
        
        // If Buddy FlarmID has changed
        if buddyFlarmIDTextField.text != UserDefaultsManager.buddyFlarmID() {
            // If Show Only Buddy Switch is on (state = true) - Reconnect to OGN Server
            if UserDefaultsManager.showOnlyBuddySwitchState() == true {
                // Set new Buddy FlarmID to UserDefaults
                UserDefaultsManager.set(flarmBuddyFlarmID: buddyFlarmIDTextField.text!)
                // Reconnect to OGN Server
                OGNSocketConnectionManager.reconnect()
            } else {
                // If Show Only Buddy Switch is off - just set the new Buddy FlarmID to UserDefaults
                UserDefaultsManager.set(flarmBuddyFlarmID: buddyFlarmIDTextField.text!)
            }
        } else {
            // Buddy FlarmID has not changed
        }
        
        // If ownFlarmID has changed
        if ownFlarmIDTextField.text != UserDefaultsManager.ownFlarmID() {
            // If Show Nearby Glider Switch is on (state = true) - Reconnect to OGN Server
            if UserDefaultsManager.showAllNearbyGlidersState() == true {
                // Set new ownFlarmID to UserDefaults
                UserDefaultsManager.set(ownFlarmID: ownFlarmIDTextField.text!)
                // Reconnect to OGN Server
                OGNSocketConnectionManager.reconnect()
            } else {
                // Show Nearby Glider Switch is off - just set the new ownFlarmID to UserDefaults
                UserDefaultsManager.set(ownFlarmID: ownFlarmIDTextField.text!)
            }
        } else {
            // Own FlarmID has not changed
        }
        
        // If Flarm Radius has changed
        let flarmRadiusString = flarmRadiusTextField.text!
        let flarmRadiusDouble = (flarmRadiusString as NSString).doubleValue
        
        if flarmRadiusDouble != UserDefaultsManager.flarmRadius() {
            // If Show Nearby Glider Switch is on (state = true)
            // AND Buddy Switch is off (state = false)
            // Reconnect to OGN Server
            if UserDefaultsManager.showAllNearbyGlidersState() == true && UserDefaultsManager.showOnlyBuddySwitchState() == false {
                // Set new flarmRadius to UserDefaults
                UserDefaultsManager.set(flarmRadius: flarmRadiusDouble)
                // Reconnect to OGN Server
                OGNSocketConnectionManager.reconnect()
            } else {
                // Show Nearby Glider Switch is off
                // OR Show only Buddy Switch is on
                // just set the new flarmRadius to UserDefaults
                UserDefaultsManager.set(flarmRadius: flarmRadiusDouble)
            }
        } else {
            // flarmRadius has not changed
        }
    }
    
    // MARK: - Action Methods
    @IBAction func gearWarningSwitchAction(_ sender: UISwitch) {
        UserDefaultsManager.set(gearWarningState: sender.isOn)
    }
    
    @IBAction func showTrackingRouteSwitchAction(_ sender: UISwitch) {
        UserDefaultsManager.set(showTrackingRouteState: sender.isOn)
    }
    
    @IBAction func showAllNearbyGlidersSwitchAction(_ sender: UISwitch) {
        UserDefaultsManager.set(showAllNearbyGlidersState: sender.isOn)
        if sender.isOn == true {
            // Connect to OGN Server with Radius Filter
            OGNSocketConnectionManager.start()
        } else {
            // Set showOnlyBuddySwitch also to off and showOnlyBuddySwitchState to false
            showOnlyBuddySwitch.setOn(false, animated: true)
            UserDefaultsManager.set(showOnlyBuddySwitchState: false)
            
            // Set collisionWarningSwitch also to off and collisionWarningState to false
            collisionWarningSwitch.setOn(false, animated: true)
            UserDefaultsManager.set(collisionWarningState: false)
            
            // Disconnect from OGN Server
            OGNSocketConnectionManager.stop()
        }
    }
    
    @IBAction func showOnlyBuddySwitchAction(_ sender: UISwitch) {
        UserDefaultsManager.set(showOnlyBuddySwitchState: sender.isOn)
        if sender.isOn == true {
            // Set showNearbyGlidersSwitch also to true and showAllNearbyGlidersState to true
            showAllNearbyGlidersSwitch.setOn(true, animated: true)
            UserDefaultsManager.set(showAllNearbyGlidersState: true)
            // Reconnect to OGN Server
            OGNSocketConnectionManager.reconnect()
        } else {
            // Reconnect to OGN Server
            OGNSocketConnectionManager.reconnect()
        }
    }
    
    @IBAction func collisionWarningSwitchAction(_ sender: UISwitch) {
        UserDefaultsManager.set(collisionWarningState: sender.isOn)
        // If Collision Warning Switch is turned on (true)
        if sender.isOn == true && showAllNearbyGlidersSwitch.isOn == false {
            // Set showNearbyGlidersSwitch also to true and showAllNearbyGlidersState to true
            showAllNearbyGlidersSwitch.setOn(true, animated: true)
            UserDefaultsManager.set(showAllNearbyGlidersState: true)
            // Connect to OGN Socket
            OGNSocketConnectionManager.start()
        } else {
            // Collision Warning Switch is turned off (false) or Nearby Glider Switch already on
        }
    }
    
    // Download updated Airport Database File from Server
    @IBAction func downloadAirportUpdatesAction(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Download Airport Updates",
                                      message: "Do you want to download an updated Airport Database from Server?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .default,
                                      handler: { action in
                                        AirportDatabase.downloadAirportsFromServer()
        }))
        alert.addAction(UIAlertAction(title: "No",
                                      style: .cancel,
                                      handler: nil))
        
        self.present(alert, animated: true)
        
    }
    
    @IBAction func centeringHelpSwitchAction(_ sender: UISwitch) {
        UserDefaultsManager.set(centeringHelpState: sender.isOn)
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
