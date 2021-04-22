//
//  Labels.swift
//  Glider Tool
//
//  Created by sonic on 03.11.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class MapLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAttachedLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init( coder: aDecoder )
        setupAttachedLabel()
    }

    internal func setupAttachedLabel() {
        clipsToBounds = true
        layer.cornerRadius = 15.0
        //layer.borderWidth = 1.0
        //layer.borderColor = UIColor.red.cgColor
        textColor = UIColor(named: "StandardTextColor")
        //textColor = UIColor.white
    }

}

// MARK: - LeftAttachedLabel
class LeftAttachedLabel: MapLabel {

    override func setupAttachedLabel() {
        super.setupAttachedLabel()
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
}
// MARK: - RightAttachedLabel
class RightAttachedLabel: MapLabel {

    override func setupAttachedLabel() {
        super.setupAttachedLabel()
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
    }
}
