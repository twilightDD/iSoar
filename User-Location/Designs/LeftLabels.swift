//
//  Labels.swift
//  Glider Tool
//
//  Created by sonic on 03.11.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class leftAttachedLabels: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLeftAttachedLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init( coder: aDecoder )
        setUpLeftAttachedLabels()
    }

    private func setUpLeftAttachedLabels() {

        clipsToBounds = true
        layer.cornerRadius = 10.0
        //testLabel.layer.borderWidth = 1.0
        //testLabel.layer.borderColor = UIColor.red.cgColor
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
    }
    
}
