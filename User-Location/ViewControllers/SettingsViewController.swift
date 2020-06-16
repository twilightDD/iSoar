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
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        
        // MARK: - Eureka Form
        form
            
            // MARK: Section Glider Settings
            +++ Section("Glider Settings")
            
            <<< TextRow { row in
                row.title = "Glider ID"
                row.value = UserDefaultsManager.gliderID()
                row.placeholder = "D-1234"
                
            }.cellSetup { cell, _ in
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
                
            }.cellSetup { cell, _ in
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
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "dot.radiowaves.left.and.right")
                
            }.onCellHighlightChanged({ (cell, row) in
                if row.isHighlighted == false {
                    let ownFlarmID = row.value
                    UserDefaultsManager.set(ownFlarmID: ownFlarmID ?? "FLRxxxxxx")
                    
                }
            })
            
            // MARK: Section User Settings
            +++ Section("User Settings")
            
            <<< IntRow { row in
                row.title = "Safety Altitude in m"
                row.value = Int(UserDefaultsManager.safetyAltitude())
                row.placeholder = "300"
                
            }.cellSetup { cell, _ in
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
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "speaker")
                
            }.onChange { row in
                guard let gearWarningState = row.value else { return }
                UserDefaultsManager.set(gearWarningState: gearWarningState)
                
            }
            
            // MARK: Section Map Settings
            +++ Section("Map Settings")
            
            <<< SegmentedRow<String> { row in
                row.title = "Map Resolution"
                row.options = ["Low", "High"]
                row.value = UserDefaultsManager.mapResolutionState()
                
            }.cellSetup { cell, _ in
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
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "checkmark.circle")
                
            }.onChange { row in
                guard let showTrackingRouteState = row.value else { return }
                UserDefaultsManager.set(showTrackingRouteState: showTrackingRouteState)
                
            }
            
            <<< SwitchRow("Centering Help") { row in
                row.title = row.tag
                row.value = UserDefaultsManager.centeringHelpState()
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "smallcircle.circle")
                
            }.onChange { row in
                guard let centeringHelpState = row.value else { return }
                UserDefaultsManager.set(centeringHelpState: centeringHelpState)
                
            }
            
            // MARK: Section Flarm Monitor
            +++ Section("FLARM Monitor")
            
            <<< SwitchRow { row in
                row.title = "Show nearby Aircrafts on Map"
                row.tag = "Show nearby Aircrafts on Map"
                row.value = UserDefaultsManager.showAllNearbyGlidersState()
                
            }.cellSetup { cell, _ in
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
                row.title = "FLARM Radius in Km"
                row.value = Int(UserDefaultsManager.flarmRadius())
                row.placeholder = "50"
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
                
            }.onChange { row in
                let flarmRadius = Double(row.value ?? 50)
                UserDefaultsManager.set(flarmRadius: flarmRadius)
                
            }
            
            <<< SwitchRow("Collision Warning") { row in
                row.title = row.tag
                row.value = UserDefaultsManager.collisionWarningState()
                
            }.cellSetup { cell, _ in
                cell.imageView?.image = UIImage(systemName: "speaker")
                
            }.onChange { row in
                guard let collisionWarningState = row.value else { return }
                UserDefaultsManager.set(collisionWarningState: collisionWarningState)
                
            }
            
            <<< SwitchRow { row in
                row.title = "Show only Buddies on Map"
                row.tag = "Show only Buddies on Map"
                row.value = UserDefaultsManager.showOnlyBuddySwitchState()
                
            }.cellSetup { cell, _ in
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
            
            // MARK: Section Miscellaneous
            +++ Section("Miscellaneous")
            
            <<< ButtonRow { row in
                row.title = "Download Airport Database Update"
                row.onCellSelection(self.buttonTapped)
        }
        
    }
    
    func buttonTapped(cell: ButtonCellOf<String>, row: ButtonRow) {
        AirportDatabase.downloadAirportsFromServer()
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
        
    }
    
}
