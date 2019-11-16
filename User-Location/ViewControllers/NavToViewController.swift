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
import AVFoundation

class NavToViewController: UIViewController, MFMailComposeViewControllerDelegate, UISearchBarDelegate {
    
    //MARK: Lets and Vars
    // Datasource
    var destinationAirportArray = [MapObjects.Airport]()
    var sortSwitchIndex = 0
    
    // Notification Observers
    var airportUpdateCompletedNotification:NSObjectProtocol?
    var airportUpdateFailedNotification:NSObjectProtocol?
    
    // Pull to Refresh of TableView
    private let refreshControl = UIRefreshControl()
    
    
    
    // SearchController
    var searchController: UISearchController!
    
    //var dataArray = [MapObjects.Airport]()
    var filteredArray = [String]()
    var shouldShowSearchResults = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var countryImageTop: UIImageView!
    @IBOutlet weak var airportName: UILabel!
    @IBOutlet weak var airportInfoButton: UIButton!
    @IBOutlet weak var airportsSortedBySwitch: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Pull to Refresh of TableView
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshAirportDatabase),
                                 for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching new Airport Database")
        
        // Search Controller
        setupSearchController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MapObjects.shared.updateDistance()
        setupTableViewDatasource()
        
        // if there is a selectedDestinationAirport, select corresponding tableViewCell
        if let selectedDestinationAirport = MapScreen.shared?.selectedDestinationAirport,
            let row = destinationAirportArray.firstIndex(of: selectedDestinationAirport) {
            
            let indexPathForSelectedDestinationAirport = IndexPath.init(row: row, section: 0)
            tableView.selectRow(at: indexPathForSelectedDestinationAirport,
                                animated: true,
                                scrollPosition: .middle)
        }
        
        updateUIForSelectedDestinationAirport()
        
        // Register Observers for notfications
        // Airport Update Completed
        airportUpdateCompletedNotification = NotificationCenter.default
            .addObserver(forName: MapObjects.airportUpdateCompletedNotificationName,
                         object: nil,
                         queue: OperationQueue.main) { [unowned self] (notification) in
                            self.setupTableViewDatasource()
                            self.refreshControl.endRefreshing()
        }
        
        // Airport Update Failed
        airportUpdateFailedNotification = NotificationCenter.default
            .addObserver(forName: MapObjects.airportUpdateFailedNotificationName,
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
    private func updateUIForSelectedDestinationAirport() {
        if let destinationAirport = MapScreen.shared?.selectedDestinationAirport {
            countryImageTop.image = UIImage(named: destinationAirport.country!)
            airportName.text = destinationAirport.name
            airportInfoButton.isHidden = false
        }
        else {
            countryImageTop.image = UIImage(named: "spacer")
            airportName.text = "Choose your Destination"
            airportInfoButton.isHidden = true
        }
    }
    
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
        MapObjects.shared.downloadMapObjectsFromServer()
        
    }
    
    // Set up Search Controller
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.searchBar.placeholder = "Search Airport"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.isActive = false
        // Place the search bar view to the tableview headerview.
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
     
        searchController.searchBar.resignFirstResponder()
    }
    
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        let searchString = searchController.searchBar.text
//
//        filteredArray = dataArray.filter({ (country) -> Bool in
//            let countryText: NSString = country
//
//            return (countryText.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
//        })
//
//        tableView.reloadData()
//    }
    
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
extension NavToViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView)
        -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
            
            if shouldShowSearchResults {
                return filteredArray.count
            }
            else {
                let numberOfRowsInSection = destinationAirportArray.count
                return numberOfRowsInSection
            }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            // get cell from tableView
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DestinationSelectionAirportTableViewCell.identifier) as? DestinationSelectionAirportTableViewCell
                else { fatalError("")}
            
            let airportForRow = destinationAirportArray[indexPath.row]
            
            // New Update
            if shouldShowSearchResults {
                cell.airportNameLabel.text = filteredArray[indexPath.row]
            }
            else {
                cell.airportNameLabel.text = airportForRow.name
                cell.icaoLabel.text = airportForRow.icao
                cell.distanceLabel.text = distanceAsReadable(airportForRow.distance)
                
                var countryImage = UIImage.init(named: "spacer")
                if let country = airportForRow.country {
                    countryImage = UIImage.init(named: country)
                }
                cell.countryImageView.image = countryImage
            }
            

            // texts in cell
//            cell.airportNameLabel.text = airportForRow.name
//            cell.icaoLabel.text = airportForRow.icao
//            cell.distanceLabel.text = distanceAsReadable(airportForRow.distance)
//
//            var countryImage = UIImage.init(named: "spacer")
//            if let country = airportForRow.country {
//                countryImage = UIImage.init(named: country)
//            }
//            cell.countryImageView.image = countryImage
            
            return cell
    }
    
}

//MARK: - Extension - UITableViewDelegate
extension NavToViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let newSelectedDestinationAirport = destinationAirportArray[indexPath.row]
        
        //if new selected destination equals the former: it means we want to cancel the navigation
        // we deselect the cell and set selectedDestinationAirport = nil
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
