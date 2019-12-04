//
//  DestinationSelectionAirportTableViewCell.swift
//  Glider Tool
//
//  Created by sonic on 21.10.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class DestinationSelectionAirportTableViewCell: UITableViewCell {

    static let identifier = "DestinationSelectionAirportTableViewCell"

    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var airportNameLabel: UILabel!
    @IBOutlet weak var icaoLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
