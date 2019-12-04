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

class RouteViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: Lets and Vars
    // Datasource
    var destinationAirportArray = [AirportDatabase.Airport]()
    var sortSwitchIndex = 0
    
    // Notification Observers
    var airportUpdateCompletedNotification:NSObjectProtocol?
    var airportUpdateFailedNotification:NSObjectProtocol?
    
    // Pull to Refresh of TableView
    private let refreshControl = UIRefreshControl()

    
    // MARK: - IBOutlets
    @IBOutlet weak var countryImageTop: UIImageView!
    @IBOutlet weak var airportName: UILabel!
    @IBOutlet weak var airportInfoButton: UIButton!
    @IBOutlet weak var airportsSortedBySwitch: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var searchBar: UISearchBar!



    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Pull to Refresh of TableView
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshAirportDatabase),
                                 for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching new Airfield Database")

        // register keyboard hide notifications to adjust tableView height if necessary.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AirportDatabase.shared.updateDistance()
        setupTableViewDatasource()
        
        // if there is a selectedDestinationAirport, select corresponding tableViewCell
        if let selectedDestinationAirport = MapScreen.shared?.selectedDestinationAirport,
            let row = destinationAirportArray.firstIndex(of: selectedDestinationAirport) {
            
            let indexPathForSelectedDestinationAirport = IndexPath.init(row: row, section: 0)
            tableView.selectRow(at: indexPathForSelectedDestinationAirport,
                                animated: true,
                                scrollPosition: .none
            )
        }
        
        updateUIForSelectedDestinationAirport()
        searchBar.placeholder = "Filter airports"
        
        // MARK: - Register Observers for notfications
        // Airport Update Completed
        airportUpdateCompletedNotification = NotificationCenter.default
            .addObserver(forName: AirportDatabase.airportUpdateCompletedNotificationName,
                         object: nil,
                         queue: OperationQueue.main) { [unowned self] (notification) in
                            
                            self.updateUIForSelectedDestinationAirport()
                            self.setupTableViewDatasource()
                            self.refreshControl.endRefreshing()
                            
                           // self.searchController.searchBar.placeholder = "Search \(self.destinationAirportArray.count) Airfields"
                            
        }
        
        // Airport Update Failed
        airportUpdateFailedNotification = NotificationCenter.default
            .addObserver(forName: AirportDatabase.airportUpdateFailedNotificationName,
                         object: nil,
                         queue: OperationQueue.main) { [unowned self] (notification) in
                            
                            let alert = UIAlertController(title: "Download failed",
                                                          message: "It seems your Device has no active internet Connection.",
                                                          preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK",
                                                          style: .default,
                                                          handler: {(alert: UIAlertAction!) in self.refreshControl.endRefreshing()}))
                            
                            self.present(alert, animated: true)
                            
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let airportUpdateCompletedNotification = airportUpdateCompletedNotification {
            NotificationCenter.default.removeObserver(airportUpdateCompletedNotification)
        }
        
        if let airportUpdateFailedNotification = airportUpdateFailedNotification {
            NotificationCenter.default.removeObserver(airportUpdateFailedNotification)
        }
    }
    
    // MARK: - Private Methods
    // updateUIForSelectedDestinationAirport
    private func updateUIForSelectedDestinationAirport() {
        if let destinationAirport = MapScreen.shared?.selectedDestinationAirport {
            countryImageTop.image = UIImage(named: destinationAirport.country!)
            airportName.text = destinationAirport.name
            airportInfoButton.isHidden = false
        }
        else {
            countryImageTop.image = UIImage(named: "destination")
            airportName.text = "Choose your Destination"
            airportInfoButton.isHidden = true
        }
    }

    
    // Setup TableViewDatasource
    private func setupTableViewDatasource() {
        guard let sortIndicator = AirportDatabase.SortIndicator(rawValue: airportsSortedBySwitch.selectedSegmentIndex)
            else { fatalError("segmentIndex not suitable for sortIndicator.")}
        
        if let destinationAirportArray = AirportDatabase.shared.filterDestinationAirports(byName: searchBar.text,
                                                                                          sortedBy: sortIndicator) {
            self.destinationAirportArray = destinationAirportArray
            
            tableView.reloadData()
        }
    }
    
    // Report missing Airport
    private func reportMissingAirport() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setToRecipients(["mail@isoar.de"])
            mailComposer.setSubject("Add missing Airport")
            mailComposer.setMessageBody("Country:<br>Elevation AMSL:<br>ICAO Code:<br>Latitude:<br>Longitude:<br>Name:<br>Radio Frequency:<br>Radio Frequency Name:<br>Runway Dimensions: (1000 x 50) <br>Runway Direction: (01/19)<br>Runway Surface: Grass / Asphalt<br>URL: www.airport.org", isHTML: true)
            
            mailComposer.mailComposeDelegate = self
            self.present(mailComposer, animated: true
                , completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error creating Mail",
                                          message: "Mail is not configured in settings app.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .cancel,
                                          handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    // Mail Composer Controller
    internal func mailComposeController(_ controller: MFMailComposeViewController,
                                        didFinishWith result: MFMailComposeResult,
                                        error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func distanceAsReadable(_ distance: CLLocationDistance?)
        -> String {
            var distanceAsReadable = ""
            
            if let distance = distance {
                let distanceInKm = distance/1000
                distanceAsReadable = String(format: "%.0f Km", distanceInKm)
            }
            
            return distanceAsReadable
    }
    
    // Pull to Refresh of TableView
    @objc private func refreshAirportDatabase(_ sender: Any) {
        
        if MapScreen.shared!.selectedDestinationAirport != nil{
            MapScreen.shared!.selectedDestinationAirport = nil
            
        }
        
        AirportDatabase.shared.downloadMapObjectsFromServer()
        
    }
    

    // adjust tableView height if necessary
    @objc private func adjustForKeyboard(notification: Notification) {
        // https://www.hackingwithswift.com/example-code/uikit/how-to-adjust-a-uiscrollview-to-fit-the-keyboard
//        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
//            else { return }
//
//        let keyboardScreenEndFrame = keyboardValue.cgRectValue
//        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame,
//                                                from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = .zero
        } else {
            // TODO: Magic number issue; 04.12.19, ph
            tableView.contentInset = UIEdgeInsets(top: 0,
                                                  left: 0,
                                                  bottom: 220, //keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                right: 0)
        }

        tableView.scrollIndicatorInsets = tableView.contentInset
    }


    // MARK: - Action Methods
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
    
}

// MARK: - Extension - UITableViewDataSource
extension RouteViewController: UITableViewDataSource {
    
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

            let airportOfInterest = destinationAirportArray[indexPath.row]

            // texts in cell
            cell.airportNameLabel.text = airportOfInterest.name
            cell.icaoLabel.text = airportOfInterest.icao
            cell.distanceLabel.text = distanceAsReadable(airportOfInterest.distance)
            
            var countryImage = UIImage.init(named: "destination")
            if let country = airportOfInterest.country {
                countryImage = UIImage.init(named: country)
            }
            cell.countryImageView.image = countryImage
            
            return cell
    }
    
}

//MARK: - Extension - UITableViewDelegate
extension RouteViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let newSelectedDestinationAirport = destinationAirportArray[indexPath.row]
        
        // If the newly selected destination equals the former:
        // it means we want to cancel the navigation
        // We deselect the active cell and set selectedDestinationAirport = nil
        if let formerSelectedDestinationAirport = MapScreen.shared!.selectedDestinationAirport,
            newSelectedDestinationAirport == formerSelectedDestinationAirport {
            MapScreen.shared!.selectedDestinationAirport = nil
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else {
            MapScreen.shared!.selectedDestinationAirport = newSelectedDestinationAirport
        }
        
        updateUIForSelectedDestinationAirport()
    }
    
}


//MARK: - Extension - UISearchBarDelegate
extension RouteViewController: UISearchBarDelegate {
    
    // Execute Search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        setupTableViewDatasource()
    }
    
    // Execute when searchBarCancelButtonClicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = nil
        setupTableViewDatasource()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}
