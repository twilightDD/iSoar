//
//  UITextField+NumberPadDoneButton.swift
//  Glider Tool
//
//  Created by Peter Hauke on 28.10.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation

import UIKit

/**
 Adds a Done-Button in top of the keyboard
 */
extension UITextField {

    @IBInspectable var doneAccessory: Bool {
        get {
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone {
                addDoneButtonOnKeyboard()
            }
        }
    }

    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width,
                                                                  height: 50))
        doneToolbar.barStyle = .default

        let flexSpaceButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                  target: nil,
                                                  action: nil)

        let doneButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done,
                                                  target: self,
                                                  action: #selector(self.doneButtonAction))

        let items = [flexSpaceButtonItem, doneButtonItem]
        doneToolbar.items = items

        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }

}
