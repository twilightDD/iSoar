//
//  GestureRecognizerExtension.swift
//  Glider Tool
//
//  Created by sonic on 24.06.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation
import UIKit

// MARK: - MapScreen:UIGestureRecognizerDelegate
extension MapScreen:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
