//
//  DirectToViewController.swift
//  Glider Tool
//
//  Created by sonic on 21.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class DirectToViewController: UIViewController {

    
    private let dataSource = ["EDSR", "EDNY", "EDTZ", "EDKN", "EDAB"]
    
    //@IBOutlet weak var detailLabel: UILabel!


    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    
    @IBOutlet weak var detailLabel: UILabel!
    
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

}



extension DirectToViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    
    
    


    
    

    
