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
class SettingsFormViewController: FormViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: - Keys
    
    static let AvailableGlidersKey = "Selected Glider"
    static let TrafficMonitorKey = "Traffic Monitor"
    static let CollisionWarningKey = "Collision Warning"
    static let ShowOnlyBuddiesOnMapKey = "Show only Buddies on Map"
    static let BuddyListKey = "Buddy List"
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        
        form.append(gliderSelectionSection())
        form.append(userSettingsSection())
        form.append(mapSettingsSection())
        form.append(trafficMonitorSection())
        form.append(miscellaneousSection())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUIAfterChangesWereMade()
        
    }
    
    // MARK: - Private Methods
    // MARK: Eureka Form Sections
    private func gliderSelectionSection()
        -> Section {
            let section = Section("Glider Selection")
                
                <<< PushRow<String>(SettingsFormViewController.AvailableGlidersKey) { row in
                    row.title = SettingsFormViewController.AvailableGlidersKey
                    row.value = UserDefaultsManager.gliderID()
                    row.presentationMode = .segueName(segueName: "GliderSelectionSegue", onDismiss: nil)
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "airplane")
            }
            
            section.tag = "Glider Selection"
            return section
    }
    
    private func userSettingsSection()
        -> Section {
            let section = Section("User Settings")
                
                <<< SliderRow("Safety") { row in
                    row.title = "Safety"
                    row.value = Float(UserDefaultsManager.safetyAltitude())
                    row.steps = 10
                    row.displayValueFor = { row in
                        return "\(Int(row ?? 0)) m"
                    }
                    
                }.cellSetup { cell, row in
                    let cellIconImage = UIImage(systemName: "heart")?.withTintColor(.red,
                                                                                    renderingMode: .alwaysOriginal)
                    cell.imageView?.image = cellIconImage
                    cell.slider.minimumValue = 0
                    cell.slider.maximumValue = 500
                    
                }.onChange { row in
                    let safetyAltitude = Double(row.value ?? 300)
                    UserDefaultsManager.set(safetyAltitude: safetyAltitude)
                    
                }
                
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
                
                <<< PushRow<String>("Selected Map") { row in
                    row.title = "Selected Map"
                    row.options = ["Austria", "Belgium", "Germany", "Italy", "Switzerland"]
                    row.value = UserDefaultsManager.mapCountry()
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "map")
                    
                }.onChange { row in
                    guard let mapCountry = row.value else { return }
                    UserDefaultsManager.set(mapCountry: mapCountry)
                    
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
                    row.title = SettingsFormViewController.TrafficMonitorKey
                    row.tag = SettingsFormViewController.TrafficMonitorKey
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
                            
                            self.form.rowBy(tag: SettingsFormViewController.CollisionWarningKey)?.baseValue = false
                            
                            self.form.rowBy(tag: SettingsFormViewController.CollisionWarningKey)?.reload()
                        }
                        
                        if UserDefaultsManager.showOnlyBuddySwitchState() == true {
                            UserDefaultsManager.set(showOnlyBuddySwitchState: false)
                            
                            self.form.rowBy(tag: SettingsFormViewController.ShowOnlyBuddiesOnMapKey)?.baseValue = false
                            
                            self.form.rowBy(tag: SettingsFormViewController.ShowOnlyBuddiesOnMapKey)?.reload()
                        }
                        
                    }
                    
                }
                
                <<< SliderRow("Radius") { row in
                    row.title = "Radius"
                    row.value = Float(UserDefaultsManager.trafficMonitorRadius())
                    row.steps = 19
                    row.displayValueFor = { row in
                        return "\(Int(row ?? 0)) Km"
                    }
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
                    cell.slider.minimumValue = 5
                    cell.slider.maximumValue = 100
                    cell.slider.addTarget(self,
                                          action: #selector(self.radiusSliderDidEndSliding),
                                          for: [.touchUpInside, .touchUpOutside])
                    
                }.onChange { row in
                    let trafficMonitorRadius = Double(row.value ?? 50)
                    UserDefaultsManager.set(trafficMonitorRadius: trafficMonitorRadius)
                    
                }
                
                <<< SwitchRow("Collision Warning") { row in
                    row.title = SettingsFormViewController.CollisionWarningKey
                    row.tag = SettingsFormViewController.CollisionWarningKey
                    row.value = UserDefaultsManager.collisionWarningState()
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "speaker")
                    
                }.onChange { row in
                    guard let collisionWarningState = row.value else { return }
                    UserDefaultsManager.set(collisionWarningState: collisionWarningState)
                    
                    if UserDefaultsManager.collisionWarningState() == true,
                        UserDefaultsManager.showAllNearbyGlidersState() == false {
                        
                        UserDefaultsManager.set(showAllNearbyGlidersState: true)
                        
                        self.form.rowBy(tag: SettingsFormViewController.TrafficMonitorKey)?.baseValue = UserDefaultsManager.showAllNearbyGlidersState()
                        
                        self.form.rowBy(tag: SettingsFormViewController.TrafficMonitorKey)?.reload()
                        
                    }
                    
                }
                
                <<< SwitchRow("Show only Buddies on Map") { row in
                    row.title = SettingsFormViewController.ShowOnlyBuddiesOnMapKey
                    row.tag = SettingsFormViewController.ShowOnlyBuddiesOnMapKey
                    row.value = UserDefaultsManager.showOnlyBuddySwitchState()
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "checkmark.circle")
                    
                }.onChange { row in
                    guard let rowValue = row.value else { return }
                    UserDefaultsManager.set(showOnlyBuddySwitchState: rowValue)
                    
                    if UserDefaultsManager.showOnlyBuddySwitchState() == true,
                        UserDefaultsManager.showAllNearbyGlidersState() == false {
                        
                        UserDefaultsManager.set(showAllNearbyGlidersState: true)
                        
                        self.form.rowBy(tag: SettingsFormViewController.TrafficMonitorKey)?.baseValue = UserDefaultsManager.showAllNearbyGlidersState()
                        
                        self.form.rowBy(tag: SettingsFormViewController.TrafficMonitorKey)?.reload()
                        
                    } else {
                        OGNSocketConnectionManager.reconnect()
                        
                    }
                    
                }
                
                <<< PushRow<Int>("Buddy List") { row in
                    row.title = "Buddy List"
                    let buddyCount = CoreDataManager.viewOnlyContext.countOfObjects(forEntityClass: Buddy.self)
                    row.value = buddyCount
                    row.presentationMode = .segueName(segueName: "BuddyListSegue", onDismiss: nil)
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "person.2")
            }
            
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
    
    private func updateUIAfterChangesWereMade() {
        
        if let availableGlidersCount = form.rowBy(tag: SettingsFormViewController.AvailableGlidersKey) as? PushRow<String> {
            availableGlidersCount.value = UserDefaultsManager.gliderID()
            availableGlidersCount.reload()
        }
        
        if let buddyList = form.rowBy(tag: SettingsFormViewController.BuddyListKey) as? PushRow<Int> {
            buddyList.value = CoreDataManager.viewOnlyContext.countOfObjects(forEntityClass: Buddy.self)
            buddyList.reload()
        }
        
    }
    
    @objc private func radiusSliderDidEndSliding() {
        if UserDefaultsManager.showOnlyBuddySwitchState() == false {
            OGNSocketConnectionManager.reconnect()
        }
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
