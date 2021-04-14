//
//  UIViewController.swift
//  Glider Tool
//
//  Created by sonic on 13.04.21.
//  Copyright © 2021 Denis Leupold. All rights reserved.
//

import UIKit

private var tabBarIsMovedOutOfScreen: Bool = false

extension UIViewController {
    func moveTabBar(animated: Bool = false, duration: TimeInterval = 0.5) {
        
        guard let tabBarController = self.tabBarController else { return }
        let frame = tabBarController.tabBar.frame
        
        if tabBarIsMovedOutOfScreen == false {
            UIView.animate(withDuration: duration, animations: {
                tabBarController.tabBar.frame = frame.offsetBy(dx: 0, dy: frame.height)
            })
            
            tabBarIsMovedOutOfScreen = true
            
        } else {
            UIView.animate(withDuration: duration, animations: {
                tabBarController.tabBar.frame = frame.offsetBy(dx: 0, dy: -frame.height)
            })
            
            tabBarIsMovedOutOfScreen = false
            
        }
        
    }
}
