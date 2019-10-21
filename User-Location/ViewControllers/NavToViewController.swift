//
//  DirectToViewController.swift
//  Glider Tool
//
//  Created by sonic on 21.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI

class NavToViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    // Datasource
    var destinationAirportArray = [MapObjects.Airport]()
    var sortSwitchIndex = 0
    
    // MARK: - IBOutlets
    @IBOutlet weak var icao: UILabel!
    @IBOutlet weak var airportName: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var airportInfoButton: UIButton!
    @IBOutlet weak var airportsSortedBySwitch: UISegmentedControl!

    @IBOutlet weak var tableView: UITableView!


    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if MapScreen.shared?.selectedDestinationAirport == nil {
            airportInfoButton.isHidden = true
        }

        MapObjects.shared.updateDistance()

        setupTableViewDatasource()
    }
    

    // MARK: - Private Methods
    // Update PickerView
    private func setupTableViewDatasource() {
        guard let sortIndicator = MapObjects.SortIndicator(rawValue: airportsSortedBySwitch.selectedSegmentIndex)
            else { fatalError("segmentIndex not suitable for sortIndicator.")}

        if let destinationAirportArray = MapObjects.shared.sortedDestinationAirports(by: sortIndicator) {
            self.destinationAirportArray = destinationAirportArray
            tableView.reloadData()
        }
    }

    // Report missing Airport
    private func reportMissingAirport() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setToRecipients(["denis@leupold.me"])
            mailComposer.setSubject("Add missing Airport")
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
    // Download Airport List from Server Button
    @IBAction func downloadAirportsButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Download Airport Updates", message: "Do you want to download an updated Airport Database from Server?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            MapObjects.shared.downloadMapObjectsFromServer()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)

        setupTableViewDatasource()
    }

    // Sort Switch
    @IBAction func sortSwitch(_ sender: UISegmentedControl) {
        setupTableViewDatasource()
    }

    // Report missing Airport Button
    @IBAction func reportMissingAirport(_ sender: UIButton) {
        reportMissingAirport()
    }

    // Airport Info Button
    @IBAction func airportInfoButton(_ sender: Any) {
        performSegue(withIdentifier: "AirportInfoSegue", sender: self)
    }

    // Cancel Button
    @IBAction func cancelButton(_ sender: Buttons) {
        // reset selectedDestinationAirport on MapScreenViewController
        MapScreen.shared!.selectedDestinationAirport = nil

        // Reset own UI
        icao.text = ""
        airportName.text = ""
        country.text = ""
        countryImage.image = UIImage(named: "spacer")

        airportInfoButton.isHidden = true

        tableView.selectRow(at: IndexPath.init(row: 0, section: 0), animated: true, scrollPosition: .top)
        tableView.deselectRow(at: IndexPath.init(row: 0, section: 0), animated: false)

        print("Route canceled")
    }

}



// MARK: - Extension - UITableViewDataSource
extension NavToViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView)
        -> Int {
            return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
            let numberOfRowsInSection = destinationAirportArray.count
            return numberOfRowsInSection
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {

            // get cell from tableView
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DestinationSelectionAirportTableViewCell.identifier) as? DestinationSelectionAirportTableViewCell
                else { fatalError("")}

            let airportForRow = destinationAirportArray[indexPath.row]

            // texts in cell
            cell.airportNameLabel.text = airportForRow.name
            cell.icaoLabel.text = airportForRow.icao
            cell.frequenceLabel.text = "\(airportForRow.radioFrequency ?? "-") MHz"

            var countryImage = UIImage.init(named: "spacer")
            if let country = airportForRow.country {
                countryImage = UIImage.init(named: country)
            }
            cell.countryImageView.image = countryImage

            if let distance = airportForRow.distance {
                let distanceInKm = distance/1000
                let distanceString = String(format: " (%.0f Km)", distanceInKm)
                cell.distanceLabel.text = distanceString
            }
            else {
                cell.detailTextLabel?.text = ""
            }


            // accessory
            if let destinationAirport = MapScreen.shared?.selectedDestinationAirport {
                if destinationAirport.icao == airportForRow.icao {
                    cell.accessoryType = .checkmark

                }
                else {
                    cell.accessoryType = .none
                }
            }
            else {
                cell.accessoryType = .none
            }


            return cell
    }

}


//MARK: - Extension - UITableViewDelegate
extension NavToViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDestinationAirport = destinationAirportArray[indexPath.row]

        icao.text = selectedDestinationAirport.icao
        airportName.text = selectedDestinationAirport.name
        country.text = selectedDestinationAirport.country
        countryImage.image = UIImage(named: country.text!)

        airportInfoButton.isHidden = false

        MapScreen.shared!.selectedDestinationAirport = selectedDestinationAirport
        tableView.reloadData()

        print("Destination: \(selectedDestinationAirport.icao) - \(selectedDestinationAirport.name)")
    }

}
