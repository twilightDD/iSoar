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
        
    // MARK: - IBOutlets
    @IBOutlet weak var airportName: UILabel!
    // ------
    @IBOutlet weak var icao: UILabel!
    @IBOutlet weak var radioNameValue: UILabel!
    @IBOutlet weak var radioFrequencyValue: UILabel!
    @IBOutlet weak var elevation: UILabel!
    @IBOutlet weak var runwayDirectionsValue: UILabel!
    @IBOutlet weak var runwayDimensionsValue: UILabel!
    @IBOutlet weak var runwaySurfaceValue: UILabel!
    // ------
    @IBOutlet weak var countryValue: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var latitudeValue: UILabel!
    @IBOutlet weak var longitudeValue: UILabel!
    // ------
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var additionalInfo: UILabel!
    // ------
    @IBOutlet weak var validationDate: UILabel!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedDestinationAirport = DestinationSelectionViewController.destinationAirport() {
            airportName.text = selectedDestinationAirport.name
            // ------
            icao.text = selectedDestinationAirport.icao
            radioNameValue.text =  selectedDestinationAirport.radioName
            radioFrequencyValue.text =  selectedDestinationAirport.radioFrequency
            elevation.text =  String(format: "%.0f m", selectedDestinationAirport.elevation)
            runwayDirectionsValue.text = selectedDestinationAirport.runwayDirections
            runwayDimensionsValue.text = selectedDestinationAirport.runwayDimensions
            runwaySurfaceValue.text = selectedDestinationAirport.runwaySurface
            // ------
            countryValue.text = selectedDestinationAirport.country
            countryImage.image = UIImage(named: countryValue.text!)
            latitudeValue.text = String(format: "%.6f", selectedDestinationAirport.latitude)
            longitudeValue.text = String(format: "%.6f", selectedDestinationAirport.longitude)
            // ------
            if let phoneNumber = selectedDestinationAirport.phone {
                callButton.setTitle("\(phoneNumber)", for: .normal)
            }
            else {
                callButton.setTitle("Keine Nummer", for: .normal)
                callButton.isEnabled = false
            }
            if let url = selectedDestinationAirport.url {
                urlButton.setTitle("\(url)", for: .normal)
            }
            else {
                urlButton.setTitle("Keine URL", for: .normal)
                urlButton.isEnabled = false
            }
            additionalInfo.text = selectedDestinationAirport.additionalInfo
            // ------
            validationDate.text = selectedDestinationAirport.validationDate
        }
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

        if let phoneString = DestinationSelectionViewController.destinationAirport()?.phone,
            let phoneURL = URL(string: "tel://\(phoneString))"),
            UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func urlButton(_ sender: Any) {
        //TODO: Hier hast du einfach Glück, weil eine URL mit Leerzeichen nicht gültig ist; 040402020, ph
        if let destinationAirportURLString = DestinationSelectionViewController.destinationAirport()?.url {
            let urlString = "https://\(destinationAirportURLString)"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
    }
    
}
