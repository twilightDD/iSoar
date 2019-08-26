//
//  DirectToViewController.swift
//  Glider Tool
//
//  Created by sonic on 21.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

import CoreLocation

class NavToViewController: UIViewController {

    var myArray = [MapObjects.Airport]()
    
    @IBOutlet weak var icao: UILabel!
    @IBOutlet weak var airportName: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createDestinationAirportList()
    }
    
    // Mark: - Sort Segmented Control Buttons
    @IBAction func sortButton(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            myArray.sort {$0.name < $1.name}
            pickerView.reloadAllComponents()
            pickerView.selectRow(0, inComponent: 0, animated: true)
        }
        else {
            myArray.sort {$0.distance! < $1.distance!}
            pickerView.reloadAllComponents()
            pickerView.selectRow(0, inComponent: 0, animated: true)
        }
    }

    @IBAction func cancelButton(_ sender: Buttons) {
        // reset selectedDestinationAirport on MapScreenViewController
        MapScreen.shared!.selectedDestinationAirport = nil
        
        // Reset own UI
        icao.text = ""
        airportName.text = ""
        country.text = ""
        countryImage.image = UIImage(named: "spacer")
        
        pickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    private func createDestinationAirportList() {
        let destinationAirports = MapObjects.shared.destinationAirports
        
        if let currentLocation = MapScreen.shared!.currentLocation {
            for var destinationAirport in destinationAirports {
                let destinationAirportLocation = CLLocation(latitude: destinationAirport.latitude,
                                                            longitude: destinationAirport.longitude)

                let currentDistance = currentLocation.distance(from: destinationAirportLocation)
                destinationAirport.updateDistance(currentDistance)

                myArray.append(destinationAirport)
            }
        }
        else {
            myArray = destinationAirports
        }
    
    }
    
    // TODO:
    /*
     -  Buttons
     - Actions zu den Buttons
     - sort nach Name
     - sort nach Entfernung
     - pickerView neu laden
     - private nicht vergessen
     - myArray.sort{ $0.distance! < $1.distance!}
     - myArray umbenennen
     */
    
}

extension NavToViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedDestinationAirport = myArray[row]
        
        icao.text = selectedDestinationAirport.icao
        airportName.text = selectedDestinationAirport.name
        country.text = selectedDestinationAirport.country
        
        countryImage.image = UIImage(named: country.text!)
        
        MapScreen.shared!.selectedDestinationAirport = selectedDestinationAirport
        
        print("Destination: \(selectedDestinationAirport.icao) - \(selectedDestinationAirport.name)")

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let destinationAirport = myArray[row]
        var titleForRow = destinationAirport.name
        if let distance = destinationAirport.distance {
            let distanceInKm = distance/1000
            let distanceString = String(format: " (%.1f Km)", distanceInKm)
            titleForRow.append(distanceString)
        }
        return titleForRow
    }
}
