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
    
    var destinationAirportArray = [MapObjects.Airport]()
    var sortSwitchIndex = 0
    
    // MARK: - IBOutlets
    @IBOutlet weak var icao: UILabel!
    @IBOutlet weak var airportName: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var airportInfoButton: UIButton!
    @IBOutlet weak var airportsSortedBySwitch: UISegmentedControl!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ToDo: bei Eintrit nich immer hidden
        airportInfoButton.isHidden = true

        MapObjects.shared.updateDistance()

        updatePickerView()
    }
    
    // MARK: - Buttons and Switches
    // Download Airport List from Server Button
    @IBAction func downloadAirportsButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Download Airport Updates?", message: "Do you want to download an updated Airport Database from Server?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            MapObjects.shared.downloadMapObjectsFromServer()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    // Sort Switch
    @IBAction func sortSwitch(_ sender: UISegmentedControl) {
         updatePickerView()
    }
    
    // Report missing Airport Button
    @IBAction func reportMissingAirport(_ sender: UIButton) {
        reportMissingAirport()
    }
    
    // Airport Info Button
    @IBAction func airportInfoButton(_ sender: Any) {        
        performSegue(withIdentifier: "AirportInfoSegue", sender: self)
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
        
        airportInfoButton.isHidden = true
        
        pickerView.selectRow(0, inComponent: 0, animated: true)
        
        print("Route canceled")
    }
    
    // MARK: - Functions
//    // Create Destination Airport List from JSON
//    private func createDestinationAirportList() {
//        destinationAirportArray.removeAll()
//
//        let destinationAirports = MapObjects.shared.destinationAirports
//
//        if let currentLocation = MapScreen.shared!.currentLocation {
//            for var destinationAirport in destinationAirports {
//                let destinationAirportLocation = CLLocation(latitude: destinationAirport.latitude,
//                                                            longitude: destinationAirport.longitude)
//
//                let currentDistance = currentLocation.distance(from: destinationAirportLocation)
//                destinationAirport.updateDistance(currentDistance)
//
//                destinationAirportArray.append(destinationAirport)
//            }
//        }
//        else {
//            destinationAirportArray = destinationAirports
//        }
//    }

    // Update PickerView
    func updatePickerView() {
        guard let sortIndicator = MapObjects.SortIndicator(rawValue: airportsSortedBySwitch.selectedSegmentIndex)
            else { fatalError("segmentIndex not suitable for sortIndicator.")}

        if let destinationAirportArray = MapObjects.shared.sortedDestinationAirports(by: sortIndicator) {
            self.destinationAirportArray = destinationAirportArray
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
        }
        else {
            let alert = UIAlertController(title: "Error creating Mail", message: "Mail is not configured in settings app.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
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
        return destinationAirportArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedDestinationAirport = destinationAirportArray[row]
        
        icao.text = selectedDestinationAirport.icao
        airportName.text = selectedDestinationAirport.name
        country.text = selectedDestinationAirport.country
        
        countryImage.image = UIImage(named: country.text!)
        
        airportInfoButton.isHidden = false
        
        MapScreen.shared!.selectedDestinationAirport = selectedDestinationAirport
        
        print("Destination: \(selectedDestinationAirport.icao) - \(selectedDestinationAirport.name)")
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let destinationAirport = destinationAirportArray[row]
        var titleForRow = destinationAirport.name
        if let distance = destinationAirport.distance {
            let distanceInKm = distance/1000
            let distanceString = String(format: " (%.0f Km)", distanceInKm)
            titleForRow.append(distanceString)
        }
        return titleForRow
    }
}
