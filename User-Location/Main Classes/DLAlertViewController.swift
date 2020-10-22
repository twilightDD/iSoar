//
//  DLAlertViewController.swift
//  Glider Tool
//
//  Created by sonic on 20.10.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import UIKit

class DLAlertViewController {
    
    static func showAlertViewController(title: String? = "Title", message: String? = nil, preferredStyle: UIAlertController.Style, on controller: UIViewController? = nil, addActionButton: Bool, actionButtonTitle: String? = "OK", cancelButtonTitle: String? = "Cancel") {
        
        let presentingViewController = controller ?? UIApplication.shared.windows.first?.rootViewController
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: preferredStyle)
        
        if addActionButton == true {
            alert.addAction(UIAlertAction(title: actionButtonTitle,
                                          style: .default,
                                          handler: nil))
        }
        
        alert.addAction(UIAlertAction(title: cancelButtonTitle,
                                          style: .cancel,
                                          handler: nil))

        presentingViewController?.present(alert, animated: true, completion: nil)
        
    }
    
}

//        DLAlertViewController.showAlertViewController(title: "Warning", message: "Warning Message", preferredStyle: .alert, addActionButton: true, actionButtonTitle: "OK", cancelButtonTitle: "Cancel")
