//
//  DirectToViewController.swift
//  Glider Tool
//
//  Created by sonic on 21.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class NavToViewController: UIViewController {

    private let dataSource = ["EDBT",
                              "EDCA",
                              "EDFA",
                              "EDFQ",
                              "EDGA",
                              "EDHA",
                              "EDHO",
                              "EDKA",
                              "EDKD",
                              "EDNA",
                              "EDOY",
                              "EDPA",
                              "EDQF",
                              "EDSW",
                              "EDXA",
                              "ETEB",
                              "ETHA",]
    
    @IBOutlet weak var detailLabel: UILabel!
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
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        detailLabel.text = dataSource[row]
        print(detailLabel.text!)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
}
