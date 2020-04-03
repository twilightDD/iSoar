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
    
    var selectedDestinationAirport = MapScreenViewController.shared!.selectedDestinationAirport
        
    // MARK: - IBOutlets
    @IBOutlet weak var airportName: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var elevation: UILabel!
    @IBOutlet weak var latitudeValue: UILabel!
    @IBOutlet weak var longitudeValue: UILabel!
    @IBOutlet weak var icao: UILabel!
    @IBOutlet weak var radioNameValue: UILabel!
    @IBOutlet weak var radioFrequencyValue: UILabel!
    @IBOutlet weak var runwayDirectionsValue: UILabel!
    @IBOutlet weak var dimensionsValue: UILabel!
    @IBOutlet weak var surfaceValue: UILabel!
    @IBOutlet weak var additionalInfo: UILabel!
    @IBOutlet weak var countryValue: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var validationDate: UILabel!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        airportName.text = selectedDestinationAirport?.name
        icao.text = selectedDestinationAirport!.icao
        radioNameValue.text =  selectedDestinationAirport?.radioName
        radioFrequencyValue.text =  selectedDestinationAirport?.radioFrequency
        runwayDirectionsValue.text = selectedDestinationAirport?.runwayDirections
        dimensionsValue.text = selectedDestinationAirport?.runwayDimensions
        surfaceValue.text = selectedDestinationAirport?.runwaySurface
        countryValue.text = selectedDestinationAirport?.country
        countryImage.image = UIImage(named: countryValue.text!)
        elevation.text =  String(format: "%.0f m", selectedDestinationAirport!.elevation)
        latitudeValue.text = String(format: "%.6f", selectedDestinationAirport!.latitude)
        longitudeValue.text = String(format: "%.6f", selectedDestinationAirport!.longitude)
        additionalInfo.text = selectedDestinationAirport?.additionalInfo
        callButton.setTitle("\(selectedDestinationAirport!.phone!)", for: .normal)
        urlButton.setTitle("\(selectedDestinationAirport!.url!)", for: .normal)
        validationDate.text = selectedDestinationAirport?.validationDate
    }
    
    // MARK: - Methods
    // Report new Data
    private func reportNewAirportData() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setToRecipients(["mail@isoar.de"])
            mailComposer.setSubject("Report new Data for \(icao.text!)")
            mailComposer.setMessageBody("Country:<br>Elevation AMSL:<br>ICAO Code:<br>Latitude:<br>Longitude:<br>Name:<br>Radio Frequency:<br>Radio Frequency Name:<br>Runway Dimensions: (1000 x 50) <br>Runway Direction: (01/19)<br>Runway Surface: Grass / Asphalt<br>URL: www.airport.org", isHTML: true)
            
            mailComposer.mailComposeDelegate = self
            self.present(mailComposer, animated: true,
                         completion: nil)
        } else {
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
    
    @IBAction func callButton(_ sender: Any) {
        
        let phone = MapScreenViewController.shared?.selectedDestinationAirport?.phone
        
        if let url = URL(string: "tel://\(phone!))"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func urlButton(_ sender: Any) {
        
        if let url = URL(string: "https://\(selectedDestinationAirport!.url!)") {
            UIApplication.shared.open(url)

        }
    }
    
}
