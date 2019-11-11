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
        selectedBackgroundView = UIView()
       // selectionStyle = .none // you can also take this line out
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected == true {
            selectedBackgroundView?.backgroundColor = UIColor(red: 17/255, green: 113/255, blue: 255/255, alpha: 0.1)
            accessoryType = .checkmark
            
        }
        else {
            selectedBackgroundView?.backgroundColor = nil
            accessoryType = .none
        }

    }

}
