//
//  SaveButton.swift
//  Glider Tool
//
//  Created by sonic on 08.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class Buttons: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    private func setupButton() {
        setTitleColor(.white, for: .normal)
        backgroundColor     = UIColor .lightGray
        titleLabel?.font    = .boldSystemFont(ofSize: 20)
        layer.cornerRadius  = frame.size.height / 2
    }
}
