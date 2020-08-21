//
//  AirportInfoViewController.swift
//  Glider Tool
//
//  Created by sonic on 05.06.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Eureka

// MARK: - AirportInfoViewController
class AirportInfoFormViewController: FormViewController {
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Airport Info"
        
        form.append(airportInfoSection())
        form.append(airportRadioSection())
        form.append(airportRunwayection())
        form.append(airportLocationSection())
        form.append(airportContactSection())
        form.append(airportAdditionalInfoSection())
        
    }
    
    // MARK: - Private Methods
    // MARK: Eureka Form Sections
    private func airportInfoSection()
        
        -> Section {
            
            guard let selectedDestinationAirport = FlightComputer.selectedDestinationAirport() else { fatalError() }
            
            let section = Section("Airport Info")
                
                <<< TextRow { row in
                    row.title = "Airport:"
                    row.tag = "Airport:"
                    row.value = selectedDestinationAirport.name
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "textformat")
                    
                }.cellUpdate { cell, row in
                    cell.titleLabel?.textColor = row.isDisabled ? .black : .black
                    cell.textField.textColor = row.isDisabled ? .black : .black
                    
                }
                
                <<< TextRow { row in
                    row.title = "ICAO Code:"
                    row.tag = "ICAO Code:"
                    row.value = selectedDestinationAirport.icao
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "textformat")
                    
                }.cellUpdate { cell, row in
                    cell.titleLabel?.textColor = row.isDisabled ? .black : .black
                    cell.textField.textColor = row.isDisabled ? .black : .black
                    
            }
            
            return section
            
    }
    
    private func airportRadioSection()
        
        -> Section {
            
            guard let selectedDestinationAirport = FlightComputer.selectedDestinationAirport() else { fatalError() }
            
            let section = Section("Radio")
                
                <<< TextRow { row in
                    row.title = "Radio:"
                    row.tag = "Radio:"
                    row.value = selectedDestinationAirport.radioName
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
                    
                }.cellUpdate { cell, row in
                    cell.titleLabel?.textColor = row.isDisabled ? .black : .black
                    cell.textField.textColor = row.isDisabled ? .black : .black
                    
                }
                
                <<< TextRow { row in
                    row.title = "Radio Frequency:"
                    row.tag = "Radio Frequency:"
                    row.value = selectedDestinationAirport.radioFrequency
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
                    
                }.cellUpdate { cell, row in
                    cell.titleLabel?.textColor = row.isDisabled ? .black : .black
                    cell.textField.textColor = row.isDisabled ? .black : .black
                    
            }
            
            return section
            
    }
    
    private func airportRunwayection()
        
        -> Section {
            
            guard let selectedDestinationAirport = FlightComputer.selectedDestinationAirport() else { fatalError() }
            
            let section = Section("Runways")
                
                <<< TextRow { row in
                    row.title = "Runway Directions:"
                    row.tag = "Runway Directions:"
                    row.value = selectedDestinationAirport.runwayDirections
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "arrow.up.arrow.down")
                    
                }.cellUpdate { cell, row in
                    cell.titleLabel?.textColor = row.isDisabled ? .black : .black
                    cell.textField.textColor = row.isDisabled ? .black : .black
                    
                }
                
                <<< TextRow { row in
                    row.title = "Runway Dimensions:"
                    row.tag = "Runway Dimensions:"
                    row.value = selectedDestinationAirport.runwayDimensions
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "arrow.right.arrow.left")
                    
                }.cellUpdate { cell, row in
                    cell.titleLabel?.textColor = row.isDisabled ? .black : .black
                    cell.textField.textColor = row.isDisabled ? .black : .black
                    
                }
                
                <<< TextRow { row in
                    row.title = "Runway Surface:"
                    row.tag = "Runway Surface:"
                    row.value = selectedDestinationAirport.runwaySurface
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "arrow.right.arrow.left")
                    
                }.cellUpdate { cell, row in
                    cell.titleLabel?.textColor = row.isDisabled ? .black : .black
                    cell.textField.textColor = row.isDisabled ? .black : .black
                    
            }
            
            return section
            
    }
    
    private func airportLocationSection()
        
        -> Section {
            
            guard let selectedDestinationAirport = FlightComputer.selectedDestinationAirport() else { fatalError() }
            
            let section = Section("Location")
                
                <<< TextRow { row in
                    row.title = "Country:"
                    row.tag = "Country:"
                    row.value = selectedDestinationAirport.country
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "textformat")
                    
                }.cellUpdate { cell, row in
                    cell.titleLabel?.textColor = row.isDisabled ? .black : .black
                    cell.textField.textColor = row.isDisabled ? .black : .black
                    
                }
                
                <<< TextRow { row in
                    row.title = "Latitude:"
                    row.tag = "Latitude:"
                    row.value = String(selectedDestinationAirport.latitude)
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "globe")
                    
                }.cellUpdate { cell, row in
                    cell.titleLabel?.textColor = row.isDisabled ? .black : .black
                    cell.textField.textColor = row.isDisabled ? .black : .black
                    
                }
                
                <<< TextRow { row in
                    row.title = "Longitude:"
                    row.tag = "Longitude:"
                    row.value = String(selectedDestinationAirport.longitude)
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "globe")
                    
                }.cellUpdate { cell, row in
                    cell.titleLabel?.textColor = row.isDisabled ? .black : .black
                    cell.textField.textColor = row.isDisabled ? .black : .black
                    
                }
                
                <<< TextRow { row in
                    row.title = "Elevation:"
                    row.tag = "Elevation:"
                    row.value = String(format: "%.0f m", selectedDestinationAirport.elevation)
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
                    
                }.cellUpdate { cell, row in
                    cell.titleLabel?.textColor = row.isDisabled ? .black : .black
                    cell.textField.textColor = row.isDisabled ? .black : .black
                    
            }
            
            return section
            
    }
    
    private func airportContactSection()
        
        -> Section {
            
            guard let selectedDestinationAirport = FlightComputer.selectedDestinationAirport() else { fatalError() }
            
            let section = Section("Contact")
                
                <<< ButtonRow { row in
                    if selectedDestinationAirport.phone?.isEmpty == false {
                        row.title = selectedDestinationAirport.phone
                    } else {
                        row.title = String("Please report Phone Number")
                        row.disabled = true
                    }
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "phone")
                    
                }.onCellSelection(self.phoneButtonTapped(cell:row:))
                
                <<< ButtonRow { row in
                    if selectedDestinationAirport.url?.isEmpty == false {
                        row.title = selectedDestinationAirport.url
                    } else {
                        row.title = String("Please report URL")
                        row.disabled = true
                    }
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "safari")
                    
                }.onCellSelection(self.urlButtonTapped(cell:row:))
            
            return section
            
    }
    
    private func airportAdditionalInfoSection()
        
        -> Section {
            
            guard let selectedDestinationAirport = FlightComputer.selectedDestinationAirport() else { fatalError() }
            
            let section = Section("Additional Informations")
                
                <<< TextAreaRow { row in
                    
                    row.title = "Additional Informations"
                    row.tag = "Additional Informations"
                    
                    if selectedDestinationAirport.additionalInfo?.isEmpty == false {
                        row.value = selectedDestinationAirport.additionalInfo
                    } else {
                        row.value = "No additional Informations"
                    }
                    
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "exclamationmark.triangle")
                    
                }.cellUpdate { cell, row in
                    if selectedDestinationAirport.additionalInfo?.isEmpty == false {
                        cell.textView.textColor = row.isDisabled ? .black : .black
                    }
                    
                }
                
                <<< TextRow { row in
                    row.title = "Validated:"
                    row.tag = "Validated:"
                    row.value = selectedDestinationAirport.validationDate
                    row.disabled = true
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "calendar")
                    
                }.cellUpdate { cell, row in
                    cell.titleLabel?.textColor = row.isDisabled ? .black : .black
                    cell.textField.textColor = row.isDisabled ? .black : .black
                    
            }
            
            return section
            
    }
    
    private func phoneButtonTapped(cell: ButtonCellOf<String>, row: ButtonRow) {
        if let phoneString = FlightComputer.selectedDestinationAirport()?.phone,
            let phoneURL = URL(string: "tel://\(phoneString))"),
            UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    private func urlButtonTapped(cell: ButtonCellOf<String>, row: ButtonRow) {
        if let destinationAirportURLString = FlightComputer.selectedDestinationAirport()?.url {
            let urlString = "https://\(destinationAirportURLString)"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    // MARK: - Action Methods
    @IBAction func dismissButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
