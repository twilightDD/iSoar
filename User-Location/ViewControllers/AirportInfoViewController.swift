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

    var selectedDestinationAirport = MapScreen.shared!.selectedDestinationAirport
    
    
    @IBOutlet weak var icao: UILabel!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        icao.text = selectedDestinationAirport!.icao

    }

    
    // MARK: - Methods
    // Report new Data
    private func reportNewAirportData() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setToRecipients(["denis@leupold.me"])
            mailComposer.setSubject("Report new Data for \(icao.text!)")
            mailComposer.setMessageBody("Country:<br>Elevation AMSL:<br>ICAO Code:<br>Latitude:<br>Longitude:<br>Name:<br>Radio Frequency:<br>Radio Frequency Name:<br>Runway Dimensions: (1000 x 50) <br>Runway Direction: (01/19)<br>Runway Surface: Grass / Asphalt<br>URL: www.airport.org", isHTML: true)
            
            mailComposer.mailComposeDelegate = self
            self.present(mailComposer, animated: true
                , completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error creating Mail", message: "Mail is not configured in settings app.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    // Mail Composer Controller
    internal func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    
    // MARK: - Action Methods
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reportNewDataButton(_ sender: Any) {
        reportNewAirportData()
    }
    
}
