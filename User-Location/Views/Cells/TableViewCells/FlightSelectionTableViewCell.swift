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

    @IBOutlet weak var flightDate: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var gliderID: UILabel!
    @IBOutlet weak var startICAO: UILabel!
    @IBOutlet weak var endICAO: UILabel!
    @IBOutlet weak var flightTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
