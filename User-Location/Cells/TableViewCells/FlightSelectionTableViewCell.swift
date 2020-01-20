//
//  FlightSelectionTableViewCell.swift
//  Glider Tool
//
//  Created by sonic on 17.01.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import UIKit

class FlightSelectionTableViewCell: UITableViewCell {
    
    static let identifier = "FlightSelectionTableViewCell"
    
    @IBOutlet weak var flightName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
