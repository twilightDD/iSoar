//
//  DLSendMail.swift
//  Glider Tool
//
//  Created by sonic on 10.03.21.
//  Copyright © 2021 Denis Leupold. All rights reserved.
//

import MessageUI

class DLSendMail {
    
    static func showSendMailViewController(subject: String,
                                           message: String,
                                           on controller: UIViewController? = nil) {
        
        let presentingViewController = controller ?? UIApplication.shared.windows.first?.rootViewController
        
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = presentingViewController as? MFMailComposeViewControllerDelegate
            mailVC.setToRecipients(["mail@isoar.de"])
            mailVC.setSubject(subject)
            mailVC.setMessageBody(message, isHTML: true)
            
            presentingViewController?.present(mailVC, animated: true, completion: nil)
        } else {
            DLAlertViewController.showAlertViewController(title: "Error creating Mail",
                                                          message: "Mail is not configured in settings app.",
                                                          preferredStyle: .alert)
        }
    }
    
    private func mailComposeController(controller: MFMailComposeViewController,
                                       didFinishWithResult result: MFMailComposeResult,
                                       error: NSError?) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
}
