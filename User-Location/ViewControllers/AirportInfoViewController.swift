//
//  AirportInfoViewController.swift
//  Glider Tool
//
//  Created by sonic on 05.06.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class AirportInfoViewController: UIViewController {

    @IBOutlet weak var Label: UILabel!
    
    @IBAction func BackToMapButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
