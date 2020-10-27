//
//  DLAlertViewController.swift
//  Glider Tool
//
//  Created by sonic on 20.10.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import UIKit

class DLAlertViewController {
    
    static func showAlertViewController(title: String? = "Title", message: String? = nil, preferredStyle: UIAlertController.Style, on controller: UIViewController? = nil, addActionButton: Bool, actionButtonTitle: String? = "OK", actionButtonHandler: ((UIAlertAction) -> Void)? = nil, addCancelButton: Bool, cancelButtonTitle: String? = "Cancel", cancelButtonHandler: ((UIAlertAction) -> Void)? = nil) {
        
        let presentingViewController = controller ?? UIApplication.shared.windows.first?.rootViewController
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: preferredStyle)
        
        if addActionButton == true {
            alert.addAction(UIAlertAction(title: actionButtonTitle,
                                          style: .default,
                                          handler: actionButtonHandler))
        }
        
        if addCancelButton == true {
            alert.addAction(UIAlertAction(title: cancelButtonTitle,
                                          style: .cancel,
                                          handler: cancelButtonHandler))
        }

        presentingViewController?.present(alert, animated: true, completion: nil)
        
    }
    
}

// Example use:
//DLAlertViewController.showAlertViewController(title: "Warning",
//                                              message: "Warning Message",
//                                              preferredStyle: .alert,
//                                              addActionButton: true,
//                                              actionButtonTitle: "OK",
//                                              actionButtonHandler: { action in print("Action will be executed...")},
//                                              cancelButtonTitle: "Cancel")
