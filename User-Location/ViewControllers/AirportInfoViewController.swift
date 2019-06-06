//
//  AirportInfoViewController.swift
//  Glider Tool
//
//  Created by sonic on 05.06.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit
import MessageUI

class AirportInfoViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var Label: UILabel!
    @IBAction func BackToMapButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func reportData(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setSubject("Wrong or missing Data")
            mailComposer.setMessageBody("Which Data is wrong or missing?", isHTML: true)
            mailComposer.setToRecipients(["denis@leupold.me"])
            mailComposer.mailComposeDelegate = self
            self.present(mailComposer, animated: true
                , completion: nil)
        } else {
            print("Email is not configured in settings app or we are not able to send an email")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

//MARK: - MailcomposerDelegate
func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    switch result {
    case .cancelled:
        print("User cancelled")
        break
    case .saved:
        print("Mail is saved by user")
        break
    case .sent:
        print("Mail is sent successfully")
        break
    case .failed:
        print("Sending mail is failed")
        break
    default:
        break
    }
    controller.dismiss(animated: true)
}

}

