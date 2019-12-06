//
//  TaskSelectionTableViewCell.swift
//  Glider Tool
//
//  Created by sonic on 06.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class TaskSelectionTableViewCell: UITableViewCell {
    
    static let identifier = "TaskSelectionTableViewCell"
    
    @IBOutlet weak var taskName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
