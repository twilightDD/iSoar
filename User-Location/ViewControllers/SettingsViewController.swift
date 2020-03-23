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
    @IBOutlet weak var gearWarningSwitch: UISwitch!
    @IBOutlet weak var showTrackingRouteSwitch: UISwitch!
    @IBOutlet weak var showFlarmBuddySwitch: UISwitch!
    @IBOutlet weak var buddyFlarmIDTextField: TextFields!
    @IBOutlet weak var showNearbyGlidersSwitch: UISwitch!

    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        gliderRatioTextField.delegate = self
        safetyAltitudeTextField.delegate = self
        gliderIDTextField.delegate = self
        buddyFlarmIDTextField.delegate = self

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
        
        // Gear Warning Switch Setup
        let gearWarningSwitchState = UserDefaultsManager.getGearWarningSwitch()
        gearWarningSwitch.isOn = gearWarningSwitchState
        
        // Tracking Route Switch Setup
        let showTrackingRouteSwitchState = UserDefaultsManager.getShowTrackingRouteSwitchKey()
        showTrackingRouteSwitch.isOn = showTrackingRouteSwitchState
        
        // Show Flarm Buddy Switch Setup
        let showFlarmBuddySwitchState = UserDefaultsManager.getShowFlarmBuddySwitchKey()
        showFlarmBuddySwitch.isOn = showFlarmBuddySwitchState
        
        // Buddy FlarmID
        let buddyFlarmID = UserDefaultsManager.getBuddyFlarmID()
        buddyFlarmIDTextField.text! = buddyFlarmID
        
        // Show nearby Gliders Switch Setup
        let showNearbyGlidersSwitchState = UserDefaultsManager.getShowNearbyGlidersSwitch()
        showNearbyGlidersSwitch.isOn = showNearbyGlidersSwitchState
        
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
        UserDefaultsManager.set(buddyFlarmID: buddyFlarmIDTextField.text!)
    }
    
    // MARK: - Action Methods
    // Gear Warning Switch
    @IBAction func gearWarningSwitch(_ sender: UISwitch) {
        UserDefaultsManager.set(gearWarningSwitch: sender.isOn)
    }

    //Show Tracking Route Switch
    @IBAction func showTrackingRouteSwitch(_ sender: UISwitch) {
        UserDefaultsManager.set(showTrackingRouteSwitch: sender.isOn)
    }
    
    //Show buddy Gliders Switch
    @IBAction func showFlarmBuddySwitch(_ sender: UISwitch) {
        UserDefaultsManager.set(showFlarmBuddySwitch: sender.isOn)
        if sender.isOn {
            showNearbyGlidersSwitch.setOn(true, animated: true)
            
            // Disconnect from OGN Server, empty Messages Set and remove all nearby Glider Annotaions from Map
            OGNSocketConnectionManager.shared.cancelConnection()
            MapScreen.shared?.GliderTelemetryDatas.removeAll()
            MapScreen.shared?.mapView.removeAnnotations(MapScreen.shared?.mapView.annotations ?? [])
            
            showNearbyGlidersSwitch(showNearbyGlidersSwitch)
        } else {
            OGNSocketConnectionManager.shared.cancelConnection()
        }
    }
    
    @IBAction func showNearbyGlidersSwitch(_ sender: UISwitch) {
        UserDefaultsManager.set(showNearbyGlidersSwitch: sender.isOn)
        if sender.isOn {
            // Connect to OGN Server with Radius Filter
            OGNSocketConnectionManager.shared.connectToOGNServerSocket()
        } else {
            showFlarmBuddySwitch.setOn(false, animated: true)
            showFlarmBuddySwitch(showFlarmBuddySwitch)
            
            // Disconnect from OGN Server, empty Messages Set and remove all nearby Glider Annotaions from Map
            OGNSocketConnectionManager.shared.cancelConnection()
            MapScreen.shared?.GliderTelemetryDatas.removeAll()
            MapScreen.shared?.mapView.removeAnnotations(MapScreen.shared?.mapView.annotations ?? [])
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
