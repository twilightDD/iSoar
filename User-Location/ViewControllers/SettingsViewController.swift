//
//  SettingsViewController.swift
//  Glider Tool
//
//  Created by sonic on 27.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit
import Eureka

// MARK: SettingsViewController
class SettingsViewController: FormViewController {
    
    // MARK: Lets and Vats
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Eureka Form
        form +++
            
            // MARK: Section Glider Settings
            Section("Glider Settings")
            
            <<< TextRow {
                $0.title = "Glider ID"
                $0.value = UserDefaultsManager.gliderID()
                $0.placeholder = "D-1234"
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "airplane")
                
            }.onChange { row in
                let gliderID = row.value
                UserDefaultsManager.set(gliderID: gliderID ?? "D-1234")
                
            }
            
            <<< IntRow {
                $0.title = "Glider Ratio"
                $0.value = Int(UserDefaultsManager.gliderRatio())
                $0.placeholder = "30"
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "arrow.down.left")
                
            }.onChange { row in
                let gliderRatio = Double(row.value ?? 20)
                UserDefaultsManager.set(gliderRatio: gliderRatio)
                
            }
            
            <<< TextRow {
                $0.title = "FLARM ID"
                $0.value = UserDefaultsManager.ownFlarmID()
                $0.placeholder = "FLRxxxxxx"
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "dot.radiowaves.left.and.right")
                
            }.onChange { row in
                let ownFlarmID = row.value
                UserDefaultsManager.set(ownFlarmID: ownFlarmID ?? "FLRxxxxxx")
                
            }
            
            // MARK: Section User Settings
            +++ Section("User Settings")
            
            <<< IntRow {
                $0.title = "Safety Altitude in m"
                $0.value = Int(UserDefaultsManager.safetyAltitude())
                $0.placeholder = "300"
                
            }.cellSetup { cell, _ in
                let cellIconImage = UIImage(systemName: "heart")?.withTintColor(.red,
                                                                                renderingMode: .alwaysOriginal)
                cell.imageView?.image = cellIconImage
                
            }.onChange { row in
                let safetyAltitude = Double(row.value ?? 20)
                UserDefaultsManager.set(safetyAltitude: safetyAltitude)
                
            }
            
            <<< SwitchRow("Gear Warning") {
                $0.title = $0.tag
                $0.value = UserDefaultsManager.gearWarningState()
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "speaker")
                
            }.onChange { row in
                let gearWarningState = row.value
                UserDefaultsManager.set(gearWarningState: gearWarningState ?? true)
                
            }
            
            <<< SwitchRow("Collision Warning") {
                $0.title = $0.tag
                $0.value = UserDefaultsManager.collisionWarningState()
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "speaker")
                
            }.onChange { row in
                let collisionWarningState = row.value
                UserDefaultsManager.set(collisionWarningState: collisionWarningState ?? true)
                
            }
            
            <<< SwitchRow("Centering Help") {
                $0.title = $0.tag
                $0.value = UserDefaultsManager.centeringHelpState()
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "smallcircle.circle")
                
            }.onChange { row in
                let centeringHelpState = row.value
                UserDefaultsManager.set(centeringHelpState: centeringHelpState ?? true)
                
            }
            
            <<< SwitchRow("Show Tracking Route on Map") {
                $0.title = $0.tag
                $0.value = UserDefaultsManager.showTrackingRouteState()
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "checkmark.circle")
                
            }.onChange { row in
                let showTrackingRouteState = row.value
                UserDefaultsManager.set(showTrackingRouteState: showTrackingRouteState ?? true)
                
            }
            
            <<< SegmentedRow<String> {
                $0.title = "Map Resolution"
                $0.options = ["Low", "High"]
                $0.value = UserDefaultsManager.mapResolutionState()
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = (UIImage(systemName: "map"))
                cell.segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                
            }.onChange { row in
                let mapResolution = row.value
                UserDefaultsManager.set(mapResolution: mapResolution ?? "High")
                
            }
            
            // MARK: Flarm Monitor
            +++ Section("FLARM Monitor")
            
            <<< SwitchRow("Show nearby Aircrafts on Map") {
                $0.title = $0.tag
                $0.value = UserDefaultsManager.showAllNearbyGlidersState()
                
            }.cellSetup { cell, _ in
                let cellIconImage = UIImage(systemName: "exclamationmark.triangle")?.withTintColor(.red,
                                                                                                   renderingMode: .alwaysOriginal)
                cell.imageView?.image = cellIconImage
                
            }.onChange { row in
                let showAllNearbyGlidersState = row.value
                UserDefaultsManager.set(showAllNearbyGlidersState: showAllNearbyGlidersState ?? true)
                
                if UserDefaultsManager.showAllNearbyGlidersState() == true {
                    // Connect to OGN Server with Radius Filter
                    OGNSocketConnectionManager.start()
                } else {
                    // Disconnect from OGN Server
                    OGNSocketConnectionManager.stop()
                }
                
                // TODO: 20200614 Den Rest hier noch machen
                //            // Set showOnlyBuddySwitch also to off and showOnlyBuddySwitchState to false
                //            showOnlyBuddySwitch.setOn(false, animated: true)
                //            UserDefaultsManager.set(showOnlyBuddySwitchState: false)
                //
                //            // Set collisionWarningSwitch also to off and collisionWarningState to false
                //            collisionWarningSwitch.setOn(false, animated: true)
                //            UserDefaultsManager.set(collisionWarningState: false)
                //
                //            // Disconnect from OGN Server
                //            OGNSocketConnectionManager.stop()
                //        }
                
            }
            
            <<< IntRow {
                $0.title = "FLARM Radius in Km"
                $0.value = Int(UserDefaultsManager.flarmRadius())
                $0.placeholder = "50"
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
                
            }.onChange { row in
                let flarmRadius = Double(row.value ?? 50)
                UserDefaultsManager.set(flarmRadius: flarmRadius)
                
            }
            
            // MARK: Buddy List
            +++ Section("Buddy List")
            
            <<< SwitchRow("Show only Buddies on Map") {
                $0.title = "Show only Buddies on Map"
                $0.tag = "Show only Buddies on Map"
                $0.value = UserDefaultsManager.showOnlyBuddySwitchState()
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "person.2")
                
            }.onChange { row in
                let showOnlyBuddySwitchState = row.value
                UserDefaultsManager.set(showOnlyBuddySwitchState: showOnlyBuddySwitchState ?? true)
                
            }
            
            <<< TextAreaRow("Buddy FLARM IDs") {
                $0.tag = "Buddy FLARM IDs"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
                $0.value = UserDefaultsManager.buddyFlarmID()
                $0.placeholder = "FLRxxxxxx/ICAxxxxxx/FLRxxxxxx"
                
            }.onChange { row in
                let flarmBuddyFlarmID = row.value
                UserDefaultsManager.set(flarmBuddyFlarmID: flarmBuddyFlarmID ?? "FLRxxxxxx/ICAxxxxxx/FLRxxxxxx")
                
        }
        
    }
    
}

// MARK: - Public Class Methods

// MARK: - Private Instance Methods


// Save Settings to User Defaults
//    private func saveSettings() {
//        let gliderRatioString = gliderRatioTextField.text!
//        let gliderRatioDouble = (gliderRatioString as NSString).doubleValue
//        UserDefaultsManager.set(gliderRatio: gliderRatioDouble)
//
//        let safetyAltitudeString = safetyAltitudeTextField.text!
//        let safetyAltitudeDouble = (safetyAltitudeString as NSString).doubleValue
//        UserDefaultsManager.set(safetyAltitude: safetyAltitudeDouble)
//
//        UserDefaultsManager.set(gliderID: gliderIDTextField.text!)
//
//        // If Buddy FlarmID has changed
//        if buddyFlarmIDTextField.text != UserDefaultsManager.buddyFlarmID() {
//            // If Show Only Buddy Switch is on (state = true) - Reconnect to OGN Server
//            if UserDefaultsManager.showOnlyBuddySwitchState() == true {
//                // Set new Buddy FlarmID to UserDefaults
//                UserDefaultsManager.set(flarmBuddyFlarmID: buddyFlarmIDTextField.text!)
//                // Reconnect to OGN Server
//                OGNSocketConnectionManager.reconnect()
//            } else {
//                // If Show Only Buddy Switch is off - just set the new Buddy FlarmID to UserDefaults
//                UserDefaultsManager.set(flarmBuddyFlarmID: buddyFlarmIDTextField.text!)
//            }
//        } else {
//            // Buddy FlarmID has not changed
//        }
//
//        // If ownFlarmID has changed
//        if ownFlarmIDTextField.text != UserDefaultsManager.ownFlarmID() {
//            // If Show Nearby Glider Switch is on (state = true) - Reconnect to OGN Server
//            if UserDefaultsManager.showAllNearbyGlidersState() == true {
//                // Set new ownFlarmID to UserDefaults
//                UserDefaultsManager.set(ownFlarmID: ownFlarmIDTextField.text!)
//                // Reconnect to OGN Server
//                OGNSocketConnectionManager.reconnect()
//            } else {
//                // Show Nearby Glider Switch is off - just set the new ownFlarmID to UserDefaults
//                UserDefaultsManager.set(ownFlarmID: ownFlarmIDTextField.text!)
//            }
//        } else {
//            // Own FlarmID has not changed
//        }
//
//        // If Flarm Radius has changed
//        let flarmRadiusString = flarmRadiusTextField.text!
//        let flarmRadiusDouble = (flarmRadiusString as NSString).doubleValue
//
//        if flarmRadiusDouble != UserDefaultsManager.flarmRadius() {
//            // If Show Nearby Glider Switch is on (state = true)
//            // AND Buddy Switch is off (state = false)
//            // Reconnect to OGN Server
//            if UserDefaultsManager.showAllNearbyGlidersState() == true && UserDefaultsManager.showOnlyBuddySwitchState() == false {
//                // Set new flarmRadius to UserDefaults
//                UserDefaultsManager.set(flarmRadius: flarmRadiusDouble)
//                // Reconnect to OGN Server
//                OGNSocketConnectionManager.reconnect()
//            } else {
//                // Show Nearby Glider Switch is off
//                // OR Show only Buddy Switch is on
//                // just set the new flarmRadius to UserDefaults
//                UserDefaultsManager.set(flarmRadius: flarmRadiusDouble)
//            }
//        } else {
//            // flarmRadius has not changed
//        }
//    }

// MARK: - Action Methods
//    @IBAction func gearWarningSwitchAction(_ sender: UISwitch) {
//        UserDefaultsManager.set(gearWarningState: sender.isOn)
//    }
//
//    @IBAction func showTrackingRouteSwitchAction(_ sender: UISwitch) {
//        UserDefaultsManager.set(showTrackingRouteState: sender.isOn)
//    }
//
//    @IBAction func showAllNearbyGlidersSwitchAction(_ sender: UISwitch) {
//        UserDefaultsManager.set(showAllNearbyGlidersState: sender.isOn)
//        if sender.isOn == true {
//            // Connect to OGN Server with Radius Filter
//            OGNSocketConnectionManager.start()
//        } else {
//            // Set showOnlyBuddySwitch also to off and showOnlyBuddySwitchState to false
//            showOnlyBuddySwitch.setOn(false, animated: true)
//            UserDefaultsManager.set(showOnlyBuddySwitchState: false)
//
//            // Set collisionWarningSwitch also to off and collisionWarningState to false
//            collisionWarningSwitch.setOn(false, animated: true)
//            UserDefaultsManager.set(collisionWarningState: false)
//
//            // Disconnect from OGN Server
//            OGNSocketConnectionManager.stop()
//        }
//    }
//
//    @IBAction func showOnlyBuddySwitchAction(_ sender: UISwitch) {
//        UserDefaultsManager.set(showOnlyBuddySwitchState: sender.isOn)
//        if sender.isOn == true {
//            // Set showNearbyGlidersSwitch also to true and showAllNearbyGlidersState to true
//            showAllNearbyGlidersSwitch.setOn(true, animated: true)
//            UserDefaultsManager.set(showAllNearbyGlidersState: true)
//            // Reconnect to OGN Server
//            OGNSocketConnectionManager.reconnect()
//        } else {
//            // Reconnect to OGN Server
//            OGNSocketConnectionManager.reconnect()
//        }
//    }
//
//    @IBAction func collisionWarningSwitchAction(_ sender: UISwitch) {
//        UserDefaultsManager.set(collisionWarningState: sender.isOn)
//        // If Collision Warning Switch is turned on (true)
//        if sender.isOn == true && showAllNearbyGlidersSwitch.isOn == false {
//            // Set showNearbyGlidersSwitch also to true and showAllNearbyGlidersState to true
//            showAllNearbyGlidersSwitch.setOn(true, animated: true)
//            UserDefaultsManager.set(showAllNearbyGlidersState: true)
//            // Connect to OGN Socket
//            OGNSocketConnectionManager.start()
//        } else {
//            // Collision Warning Switch is turned off (false) or Nearby Glider Switch already on
//        }
//    }
//
//    // Download updated Airport Database File from Server
//    @IBAction func downloadAirportUpdatesAction(_ sender: UIButton) {
//
//        let alert = UIAlertController(title: "Download Airport Updates",
//                                      message: "Do you want to download an updated Airport Database from Server?",
//                                      preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Yes",
//                                      style: .default,
//                                      handler: { action in
//                                        AirportDatabase.downloadAirportsFromServer()
//        }))
//        alert.addAction(UIAlertAction(title: "No",
//                                      style: .cancel,
//                                      handler: nil))
//
//        self.present(alert, animated: true)
//
//    }
//
//    @IBAction func centeringHelpSwitchAction(_ sender: UISwitch) {
//        UserDefaultsManager.set(centeringHelpState: sender.isOn)
//    }
//
//    @IBAction func mapResolutionSegmentedControlAction(_ sender: UISegmentedControl) {
//        UserDefaultsManager.set(mapResolution: mapResolutionSegmentedControl.selectedSegmentIndex)
//    }
//
//}

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
        //saveSettings()
    }
    
}
