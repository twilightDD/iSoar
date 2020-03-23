//
//  TextFields.swift
//  Glider Tool
//
//  Created by sonic on 08.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class TextFields: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpTextField()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init( coder: aDecoder )
        setUpTextField()
    }

    private func setUpTextField() {
        // Color presets
        var textColor: UIColor
        var backgroundColor: UIColor

        if #available(iOS 13, *) {
            textColor = .label
            backgroundColor = .systemBackground
        } else {
            textColor = .darkText
            backgroundColor = .white
        }

        self.textColor       = textColor
        self.backgroundColor = backgroundColor
    }

}
