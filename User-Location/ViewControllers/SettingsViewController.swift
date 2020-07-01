//
//  SettingsViewController.swift
//  Glider Tool
//
//  Created by sonic on 27.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Eureka
import MessageUI
import UIKit

// MARK: SettingsViewController
class SettingsViewController: FormViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: Lets and Vars
    
    // MARK: - Keys
    
    static let AvailableGlidersKey = "Available Gliders"
    static let GliderRegistrationKey = "Glider Registration"
    static let GliderRatioKey = "Glider Ratio"
    static let GliderFlarmIDKey = "FLARM ID"
    
    static let TrafficMonitorKey = "Traffic Monitor"
    static let CollisionWarningKey = "Collision Warning"
    static let ShowOnlyBuddiesOnMapKey = "Show only Buddies on Map"
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        
        form.append(gliderSelectionSection())
        form.append(selectedGliderSection())
        form.append(userSettingsSection())
        form.append(mapSettingsSection())
        form.append(trafficMonitorSection())
        form.append(miscellaneousSection())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        updateUIforSelectedGlider()
        
    }
    
    // MARK: - Private Methods
    // MARK: Eureka Form Sections
    
    private func gliderSelectionSection()
        -> Section {
            let section = Section("Glider Selection")
            
                <<< ButtonRow { row in
                    row.title = SettingsViewController.AvailableGlidersKey
                    row.tag = SettingsViewController.AvailableGlidersKey
                    row.presentationMode = .segueName(segueName: "GliderSelectionSegue", onDismiss: nil)
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "airplane")

            }
            
            section.tag = "Glider Selection"
            return section
    }
    
    private func selectedGliderSection()
                -> Section {
                    let section = Section("Selected Glider Details")
                    
                <<< TextRow { row in
                    row.title = SettingsViewController.GliderRegistrationKey
                    row.tag = SettingsViewController.GliderRegistrationKey
                    row.value = UserDefaultsManager.gliderID()
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "textformat")
                }
                
                <<< TextRow { row in
                    row.title = SettingsViewController.GliderRatioKey
                    row.tag = SettingsViewController.GliderRatioKey
                    row.value = String(format: "%.0f", UserDefaultsManager.gliderRatio())
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "arrow.down.left")
                }
                
                <<< TextRow { row in
                    row.title = SettingsViewController.GliderFlarmIDKey
                    row.tag = SettingsViewController.GliderFlarmIDKey
                    row.value = UserDefaultsManager.ownFlarmID()
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "dot.radiowaves.left.and.right")
                    
            }

            section.tag = "Selected Glider Details"
            return section
            
    }

    private func userSettingsSection()
        -> Section {
            let section = Section("User Settings")
                <<< IntRow { row in
                    row.title = "Safety Altitude (m)"
                    row.value = Int(UserDefaultsManager.safetyAltitude())
                    row.placeholder = "300"
                    
                }.cellSetup { cell, row in
                    let cellIconImage = UIImage(systemName: "heart")?.withTintColor(.red,
                                                                                    renderingMode: .alwaysOriginal)
                    cell.imageView?.image = cellIconImage
                    
                }.onCellHighlightChanged({ (cell, row) in
                    if row.isHighlighted == false {
                        let safetyAltitude = Double(row.value ?? 300)
                        UserDefaultsManager.set(safetyAltitude: safetyAltitude)
                        
                    }
                })
                
                <<< SwitchRow("Gear Warning") { row in
                    row.title = row.tag
                    row.value = UserDefaultsManager.gearWarningState()
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "speaker")
                    
                }.onChange { row in
                    guard let gearWarningState = row.value else { return }
                    UserDefaultsManager.set(gearWarningState: gearWarningState)
                    
            }
            
            return section
    }
    
    private func mapSettingsSection()
        -> Section {
            let section = Section("Map Settings")
                <<< SegmentedRow<String> { row in
                    row.title = "Map Resolution"
                    row.options = ["Low", "High"]
                    row.value = UserDefaultsManager.mapResolutionState()
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = (UIImage(systemName: "map"))
                    cell.segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                    
                }.onChange { row in
                    guard let mapResolution = row.value else { return }
                    UserDefaultsManager.set(mapResolution: mapResolution)
                    
                }
                
                <<< SwitchRow { row in
                    row.title = "Show Tracking Route on Map"
                    row.tag = "Show Tracking Route on Map"
                    row.value = UserDefaultsManager.showTrackingRouteState()
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "checkmark.circle")
                    
                }.onChange { row in
                    guard let showTrackingRouteState = row.value else { return }
                    UserDefaultsManager.set(showTrackingRouteState: showTrackingRouteState)
                    
                }
                
                <<< SwitchRow("Centering Help") { row in
                    row.title = row.tag
                    row.value = UserDefaultsManager.centeringHelpState()
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "smallcircle.circle")
                    
                }.onChange { row in
                    guard let centeringHelpState = row.value else { return }
                    UserDefaultsManager.set(centeringHelpState: centeringHelpState)
                    
            }
            return section
    }
    
    private func trafficMonitorSection()
        -> Section {
            let section = Section("Traffic Monitor Settings")
                <<< SwitchRow { row in
                    row.title = SettingsViewController.TrafficMonitorKey
                    row.tag = SettingsViewController.TrafficMonitorKey
                    row.value = UserDefaultsManager.showAllNearbyGlidersState()
                    
                }.cellSetup { cell, row in
                    let cellIconImage = UIImage(systemName: "exclamationmark.triangle")?.withTintColor(.red,
                                                                                                       renderingMode: .alwaysOriginal)
                    cell.imageView?.image = cellIconImage
                    
                }.onChange { row in
                    guard let showAllNearbyGlidersState = row.value else { return }
                    UserDefaultsManager.set(showAllNearbyGlidersState: showAllNearbyGlidersState)
                    
                    if UserDefaultsManager.showAllNearbyGlidersState() == true {
                        // Connect to OGN Server with Radius Filter
                        OGNSocketConnectionManager.start()
                        
                    } else {
                        // Disconnect from OGN Server
                        OGNSocketConnectionManager.stop()
                        
                        if UserDefaultsManager.collisionWarningState() == true {
                            UserDefaultsManager.set(collisionWarningState: false)
                            
                            self.form.rowBy(tag: SettingsViewController.CollisionWarningKey)?.baseValue = false
                            
                            self.form.rowBy(tag: SettingsViewController.CollisionWarningKey)?.reload()
                        }
                        
                        if UserDefaultsManager.showOnlyBuddySwitchState() == true {
                            UserDefaultsManager.set(showOnlyBuddySwitchState: false)
                            
                            self.form.rowBy(tag: SettingsViewController.ShowOnlyBuddiesOnMapKey)?.baseValue = false
                            
                            self.form.rowBy(tag: SettingsViewController.ShowOnlyBuddiesOnMapKey)?.reload()
                        }
                        
                    }
                    
                }
                
                <<< IntRow { row in
                    row.title = "Traffic Monitor Radius (Km)"
                    row.value = Int(UserDefaultsManager.trafficMonitorRadius())
                    row.placeholder = "50"
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
                    
                }.onCellHighlightChanged({ (cell, row) in
                    if row.isHighlighted == false {
                        
                        let trafficMonitorRadius = Double(row.value ?? 50)
                        UserDefaultsManager.set(trafficMonitorRadius: trafficMonitorRadius)
                        
                        if UserDefaultsManager.showOnlyBuddySwitchState() == false {
                            OGNSocketConnectionManager.reconnect()
                        }
                        
                    }
                    
                })
                
                <<< SwitchRow("Collision Warning") { row in
                    row.title = SettingsViewController.CollisionWarningKey
                    row.tag = SettingsViewController.CollisionWarningKey
                    row.value = UserDefaultsManager.collisionWarningState()
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "speaker")
                    
                }.onChange { row in
                    guard let collisionWarningState = row.value else { return }
                    UserDefaultsManager.set(collisionWarningState: collisionWarningState)
                    
                    if UserDefaultsManager.collisionWarningState() == true,
                        UserDefaultsManager.showAllNearbyGlidersState() == false {
                        
                        UserDefaultsManager.set(showAllNearbyGlidersState: true)
                        
                        self.form.rowBy(tag: SettingsViewController.TrafficMonitorKey)?.baseValue = UserDefaultsManager.showAllNearbyGlidersState()
                        
                        self.form.rowBy(tag: SettingsViewController.TrafficMonitorKey)?.reload()
                        
                    }
                    
                }
                
                <<< SwitchRow("Show only Buddies on Map") { row in
                    row.title = SettingsViewController.ShowOnlyBuddiesOnMapKey
                    row.tag = SettingsViewController.ShowOnlyBuddiesOnMapKey
                    row.value = UserDefaultsManager.showOnlyBuddySwitchState()
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "person.2")
                    
                }.onChange { row in
                    guard let rowValue = row.value else { return }
                    UserDefaultsManager.set(showOnlyBuddySwitchState: rowValue)
                    
                    if UserDefaultsManager.showOnlyBuddySwitchState() == true,
                        UserDefaultsManager.showAllNearbyGlidersState() == false {
                        
                        UserDefaultsManager.set(showAllNearbyGlidersState: true)
                        
                        self.form.rowBy(tag: SettingsViewController.TrafficMonitorKey)?.baseValue = UserDefaultsManager.showAllNearbyGlidersState()
                        
                        self.form.rowBy(tag: SettingsViewController.TrafficMonitorKey)?.reload()
                        
                    } else {
                        OGNSocketConnectionManager.reconnect()
                        
                    }
                    
                }
                
                <<< LabelRow { row in
                    row.title = "Buddy FLARM IDs"
                    row.cellStyle = .default
                    
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                })
                
                <<< TextAreaRow("Buddy FLARM IDs") { row in
                    row.title = "Buddy FLARM IDs"
                    row.tag = "Buddy FLARM IDs"
                    row.textAreaHeight = .dynamic(initialTextViewHeight: 50)
                    row.value = UserDefaultsManager.buddyFlarmID()
                    row.placeholder = "FLRxxxxxx/ICAxxxxxx/FLRxxxxxx"
                    
                }.onCellHighlightChanged({ (cell, row) in
                    if row.isHighlighted == false {
                        
                        let flarmBuddyFlarmID = row.value
                        UserDefaultsManager.set(flarmBuddyFlarmID: flarmBuddyFlarmID ?? "FLRxxxxxx")
                        
                        if UserDefaultsManager.showAllNearbyGlidersState() == true,
                            UserDefaultsManager.showOnlyBuddySwitchState() == true {
                            
                            OGNSocketConnectionManager.reconnect()
                            
                        }
                        
                    }
                })
            return section
    }
    
    private func miscellaneousSection()
        -> Section {
            let section = Section("Miscellaneous")
                <<< ButtonRow { row in
                    row.title = "Download Airport Database Update"
                    row.onCellSelection(self.downloadButtonTapped)
                    
                }
                
                <<< ButtonRow { row in
                    row.title = "Report missing Airfield"
                    row.onCellSelection(self.reportMissingAirfieldButtonTapped)
                    
                }
                
                <<< ButtonRow { row in
                    row.title = "Read the Manual (German)"
                    row.onCellSelection(self.readTheManualButtonTapped)
                    
            }
            return section
    }
    
    // Report missing Airport
    private func reportMissingAirport() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setToRecipients(["mail@isoar.de"])
            mailComposer.setSubject("Add missing Airport")
            mailComposer.setMessageBody("Country:<br>Elevation AMSL:<br>ICAO Code:<br>Latitude:<br>Longitude:<br>Name:<br>Radio Frequency:<br>Radio Frequency Name:<br>Runway Dimensions: (1000 x 50) <br>Runway Direction: (01/19)<br>Runway Surface: Grass / Asphalt<br>URL: www.airport.org", isHTML: true)
            
            mailComposer.mailComposeDelegate = self
            self.present(mailComposer, animated: true,
                         completion: nil)
        } else {
            let alert = UIAlertController(title: "Error creating Mail",
                                          message: "Mail is not configured in settings app.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .cancel,
                                          handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    // Mail Composer Controller
    internal func mailComposeController(_ controller: MFMailComposeViewController,
                                        didFinishWith result: MFMailComposeResult,
                                        error: Error?) {
        controller.dismiss(animated: true)
    }
    
    private func updateUIforSelectedGlider() {

        let gliderID = form.rowBy(tag: SettingsViewController.GliderRegistrationKey) as? TextRow
        gliderID!.value = UserDefaultsManager.gliderID()
        gliderID!.reload()
        
        let gliderRatio = form.rowBy(tag: SettingsViewController.GliderRatioKey) as? TextRow
        gliderRatio!.value = String(format: "%.0f", UserDefaultsManager.gliderRatio())
        gliderRatio!.reload()
        
        let gliderFlarmID = form.rowBy(tag: SettingsViewController.GliderFlarmIDKey) as? TextRow
        gliderFlarmID!.value = UserDefaultsManager.ownFlarmID()
        gliderFlarmID!.reload()
        
    }
    
    // MARK: - Action Methods
    private func downloadButtonTapped(cell: ButtonCellOf<String>, row: ButtonRow) {
        AirportDatabase.downloadAirportsFromServer()
    }
    
    private func reportMissingAirfieldButtonTapped(cell: ButtonCellOf<String>, row: ButtonRow) {
        reportMissingAirport()
    }
    
    private func readTheManualButtonTapped(cell: ButtonCellOf<String>, row: ButtonRow) {
        if let manualURL = Presets.Settings.maualURL,
            UIApplication.shared.canOpenURL(manualURL as URL) {
            UIApplication.shared.open(manualURL)
        }
        
    }
    
}
