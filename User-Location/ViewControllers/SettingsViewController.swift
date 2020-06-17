//
//  SettingsViewController.swift
//  Glider Tool
//
//  Created by sonic on 27.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Eureka

// MARK: SettingsViewController
class SettingsViewController: FormViewController {
    
    // MARK: Lets and Vats
    
    // MARK: Eureka Form Sections
    private func gliderSettingsSection()
        -> Section {
            let section = Section("Glider Settings")
                <<< TextRow { row in
                    row.title = "Glider ID"
                    row.value = UserDefaultsManager.gliderID()
                    row.placeholder = "D-1234"
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "airplane")
                    
                }.onCellHighlightChanged({ (cell, row) in
                    if row.isHighlighted == false {
                        let gliderID = row.value
                        UserDefaultsManager.set(gliderID: gliderID ?? "D-1234")
                        
                    }
                })
                
                <<< IntRow { row in
                    row.title = "Glider Ratio"
                    row.value = Int(UserDefaultsManager.gliderRatio())
                    row.placeholder = "30"
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "arrow.down.left")
                    
                }.onCellHighlightChanged({ (cell, row) in
                    if row.isHighlighted == false {
                        let gliderRatio = Double(row.value ?? 30)
                        UserDefaultsManager.set(gliderRatio: gliderRatio)
                        
                    }
                })
                
                <<< TextRow { row in
                    row.title = "FLARM ID"
                    row.value = UserDefaultsManager.ownFlarmID()
                    row.placeholder = "FLRxxxxxx"
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "dot.radiowaves.left.and.right")
                    
                }.onCellHighlightChanged({ (cell, row) in
                    if row.isHighlighted == false {
                        let ownFlarmID = row.value
                        UserDefaultsManager.set(ownFlarmID: ownFlarmID ?? "FLRxxxxxx")
                        
                    }
                })
            
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
                    row.title = "Traffic Monitor"
                    row.tag = "Traffic Monitor"
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
                        
                        OGNSocketConnectionManager.reconnect()
                        
                    }
                    
                })
                
                <<< SwitchRow("Collision Warning") { row in
                    row.title = row.tag
                    row.value = UserDefaultsManager.collisionWarningState()
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "speaker")
                    
                }.onChange { row in
                    guard let collisionWarningState = row.value else { return }
                    UserDefaultsManager.set(collisionWarningState: collisionWarningState)
                    
                }
                
                <<< SwitchRow { row in
                    row.title = "Show only Buddies on Map"
                    row.tag = "Show only Buddies on Map"
                    row.value = UserDefaultsManager.showOnlyBuddySwitchState()
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "person.2")
                    
                }.onChange { row in
                    guard let rowValue = row.value else { return }
                    UserDefaultsManager.set(showOnlyBuddySwitchState: rowValue)
                    
                    if UserDefaultsManager.showOnlyBuddySwitchState() == true,
                        UserDefaultsManager.showAllNearbyGlidersState() == false {
                        
                        UserDefaultsManager.set(showAllNearbyGlidersState: true)
                        
                        self.form.rowBy(tag: "Show nearby Aircrafts on Map")?.baseValue = UserDefaultsManager.showAllNearbyGlidersState()
                        
                        self.form.rowBy(tag: "Show nearby Aircrafts on Map")?.reload()
                        
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
            let section = Section("Miscellaneous Settings")
                <<< ButtonRow { row in
                    row.title = "Download Airport Database Update"
                    row.onCellSelection(self.buttonTapped)
            }
            return section
    }
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        
        // MARK: - Eureka Form
        form.append(gliderSettingsSection())
        form.append(userSettingsSection())
        form.append(mapSettingsSection())
        form.append(trafficMonitorSection())
        form.append(miscellaneousSection())
        
    }
    
    // MARK: - Private Methods
    private func buttonTapped(cell: ButtonCellOf<String>, row: ButtonRow) {
        AirportDatabase.downloadAirportsFromServer()
    }
    
}
