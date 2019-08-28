//
//  DirectToViewController.swift
//  Glider Tool
//
//  Created by sonic on 21.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI

class NavToViewController: UIViewController, MFMailComposeViewControllerDelegate {

    var destinationAirportListArray = [MapObjects.Airport]()
    
    var sortSwitchIndex = 0
    
    // MARK: - IBOutlets
    @IBOutlet weak var icao: UILabel!
    @IBOutlet weak var airportName: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createDestinationAirportList()
        updatePickerView()

    }
    
    // MARK: - Buttons and Switches
    // Sort Switch    
    @IBAction func sortSwitch(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            sortSwitchIndex = sender.selectedSegmentIndex
            destinationAirportListArray.sort {$0.name < $1.name}
            pickerView.reloadAllComponents()
            //pickerView.selectRow(0, inComponent: 0, animated: true)
        }
        else {
            sortSwitchIndex = sender.selectedSegmentIndex
            destinationAirportListArray.sort {$0.distance! < $1.distance!}
            pickerView.reloadAllComponents()
            //pickerView.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    // Report missing Airport Button
    @IBAction func reportMissingAirport(_ sender: Any) {
        reportMissingAirport()
    }
    
    // Cancel Button
    @IBAction func cancelButton(_ sender: Buttons) {
        // reset selectedDestinationAirport on MapScreenViewController
        MapScreen.shared!.selectedDestinationAirport = nil
        
        // Reset own UI
        icao.text = ""
        airportName.text = ""
        country.text = ""
        countryImage.image = UIImage(named: "spacer")
        
        pickerView.selectRow(0, inComponent: 0, animated: true)
        
        print("Route canceled")
    }
    
    // MARK: - Functions
    // Create Destination Airport List from JSON
    private func createDestinationAirportList() {
        destinationAirportListArray.removeAll()
        let destinationAirports = MapObjects.shared.destinationAirports
        
        if let currentLocation = MapScreen.shared!.currentLocation {
            for var destinationAirport in destinationAirports {
                let destinationAirportLocation = CLLocation(latitude: destinationAirport.latitude,
                                                            longitude: destinationAirport.longitude)
                
                let currentDistance = currentLocation.distance(from: destinationAirportLocation)
                destinationAirport.updateDistance(currentDistance)
                
                destinationAirportListArray.append(destinationAirport)
            }
        }
        else {
            destinationAirportListArray = destinationAirports
            }
        }
    
    // Update PickerView
    func updatePickerView(){
        if sortSwitchIndex == 0 {
            destinationAirportListArray.sort {$0.name < $1.name}
            pickerView.reloadAllComponents()
        }
        else {
            destinationAirportListArray.sort {$0.distance! < $1.distance!}
            pickerView.reloadAllComponents()
        }
    }
    
    // Report missing Airport
    func reportMissingAirport() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setToRecipients(["denis@leupold.me"])
            mailComposer.setSubject("Add missing Airport")
            mailComposer.setMessageBody("Country:<br>Elevation AMSL:<br>ICAO Code:<br>Latitude:<br>Longitude:<br>Name:<br>Radio Frequency:<br>Radio Frequency Name:<br>Runway Dimensions: (1000 x 50) <br>Runway Direction: (01/19)<br>Runway Surface: Grass / Asphalt<br>URL: www.airport.org", isHTML: true)
            
            mailComposer.mailComposeDelegate = self
            self.present(mailComposer, animated: true
                , completion: nil)
        } else {
            print("Email is not configured in settings app.")
        }
    }
    
    // Mail Composer Controller
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    }

// MARK: - Extensions
extension NavToViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return destinationAirportListArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedDestinationAirport = destinationAirportListArray[row]
        
        icao.text = selectedDestinationAirport.icao
        airportName.text = selectedDestinationAirport.name
        country.text = selectedDestinationAirport.country
        
        countryImage.image = UIImage(named: country.text!)
        
        MapScreen.shared!.selectedDestinationAirport = selectedDestinationAirport
        
        print("Destination: \(selectedDestinationAirport.icao) - \(selectedDestinationAirport.name)")

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let destinationAirport = destinationAirportListArray[row]
        var titleForRow = destinationAirport.name
        if let distance = destinationAirport.distance {
            let distanceInKm = distance/1000
            let distanceString = String(format: " (%.1f Km)", distanceInKm)
            titleForRow.append(distanceString)
        }
        return titleForRow
    }
}
