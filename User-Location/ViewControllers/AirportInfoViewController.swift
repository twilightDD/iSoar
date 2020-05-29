//
//  AirportInfoViewController.swift
//  Glider Tool
//
//  Created by sonic on 05.06.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit
import MessageUI

// MARK: - AirportInfoViewController
class AirportInfoViewController: UIViewController {
        
    // MARK: IBOutlets
    @IBOutlet private weak var airportNameLabel: UILabel!
    // ------
    @IBOutlet private weak var icaoLabel: UILabel!
    @IBOutlet private weak var radioNameLabel: UILabel!
    @IBOutlet private weak var radioFrequencyLabel: UILabel!
    @IBOutlet private weak var elevationLabel: UILabel!
    @IBOutlet private weak var runwayDirectionsLabel: UILabel!
    @IBOutlet private weak var runwayDimensionsLabel: UILabel!
    @IBOutlet private weak var runwaySurfaceLabel: UILabel!
    // ------
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var countryImageView: UIImageView!
    @IBOutlet private weak var latitudeLabel: UILabel!
    @IBOutlet private weak var longitudeLabel: UILabel!
    // ------
    @IBOutlet private weak var callButton: UIButton!
    @IBOutlet private weak var urlButton: UIButton!
    @IBOutlet private weak var additionalInfoLabel: UILabel!
    // ------
    @IBOutlet private weak var validationDateLabel: UILabel!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedDestinationAirport = FlightComputer.selectedDestinationAirport() {
            airportNameLabel.text = selectedDestinationAirport.name
            // ------
            icaoLabel.text = selectedDestinationAirport.icao
            radioNameLabel.text =  selectedDestinationAirport.radioName
            radioFrequencyLabel.text =  selectedDestinationAirport.radioFrequency
            elevationLabel.text =  String(format: "%.0f m", selectedDestinationAirport.elevation)
            runwayDirectionsLabel.text = selectedDestinationAirport.runwayDirections
            runwayDimensionsLabel.text = selectedDestinationAirport.runwayDimensions
            runwaySurfaceLabel.text = selectedDestinationAirport.runwaySurface
            // ------
            countryLabel.text = selectedDestinationAirport.country
            latitudeLabel.text = String(format: "%.6f", selectedDestinationAirport.latitude)
            longitudeLabel.text = String(format: "%.6f", selectedDestinationAirport.longitude)
            // ------
            if let phoneNumber = selectedDestinationAirport.phone {
                callButton.setTitle("\(phoneNumber)", for: .normal)
            } else {
                callButton.setTitle("Please report Phone Number", for: .normal)
                callButton.isEnabled = false
            }
            if let url = selectedDestinationAirport.url {
                urlButton.setTitle("\(url)", for: .normal)
            } else {
                urlButton.setTitle("Please report URL", for: .normal)
                urlButton.isEnabled = false
            }
            additionalInfoLabel.text = selectedDestinationAirport.additionalInfo
            // ------
            validationDateLabel.text = selectedDestinationAirport.validationDate
        }
    }
    
    // MARK: - Action Methods
    @IBAction func dismissButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reportNewDataButtonAction(_ sender: Any) {
        reportNewAirportData()
    }
    
    @IBAction func callButtonAction(_ sender: Any) {

        if let phoneString = FlightComputer.selectedDestinationAirport()?.phone,
            let phoneURL = URL(string: "tel://\(phoneString))"),
            UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func urlButtonAction(_ sender: Any) {
        
        if let destinationAirportURLString = FlightComputer.selectedDestinationAirport()?.url {
            let urlString = "https://\(destinationAirportURLString)"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
    }
    
}

// MARK: - Extension - MFMailComposeViewControllerDelegate
extension AirportInfoViewController: MFMailComposeViewControllerDelegate {

    // MARK: Private Methods
    private func reportNewAirportData() {

        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setToRecipients(["mail@isoar.de"])
            mailComposer.setSubject("Report new Data for \(icaoLabel.text!)")
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

    // MARK: MFMailComposeViewControllerDelegate Methods
    internal func mailComposeController(_ controller: MFMailComposeViewController,
                                        didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
