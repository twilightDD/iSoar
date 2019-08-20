//
//  DirectToViewController.swift
//  Glider Tool
//
//  Created by sonic on 21.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class NavToViewController: UIViewController {
    
    @IBOutlet weak var icao: UILabel!
    @IBOutlet weak var airportName: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    @IBAction func cancelButton(_ sender: Buttons) {
        cancelRoute()
    }
    
    func cancelRoute(){
        
        // Hier würde ich aber eher selectedDestinationAirport vom NavTo prüfen und nil setzen wollen, als den vom MapScreen.
        if MapScreen.shared!.selectedDestinationAirport != nil {
            MapScreen.shared!.resetDestinationLabels()
            MapScreen.shared!.resetDirectionLine()
            
            icao.text = nil
            airportName.text = nil
            country.text = nil
            
            print("Route canceled")
        }
        else {
            return
        }
    }
    
}

extension NavToViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MapObjects.shared.destinationAirports.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedDestinationAirport = MapObjects.shared.destinationAirports[row]
        
        icao.text = selectedDestinationAirport.icao
        airportName.text = selectedDestinationAirport.name
        country.text = selectedDestinationAirport.country
        
        MapScreen.shared!.selectedDestinationAirport = selectedDestinationAirport
        
        print("Destination: \(selectedDestinationAirport.icao)")

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return MapObjects.shared.destinationAirports[row].name
    }
    
}
