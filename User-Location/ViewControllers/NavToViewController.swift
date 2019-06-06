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
        // Do any additional setup after loading the view, typically from a nib.
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
        print(icao.text!)
        
        airportName.text = selectedDestinationAirport.name
        print(airportName.text!)
        
        country.text = selectedDestinationAirport.country
        print(country.text!)
        
        MapScreen.shared.selectedDestinationAirport = selectedDestinationAirport
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return MapObjects.shared.destinationAirports[row].name
    }
}
