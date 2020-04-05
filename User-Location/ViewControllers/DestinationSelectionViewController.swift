//
//  DestinationSelectionViewController.swift
//  Glider Tool
//
//  Created by sonic on 21.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI

class DestinationSelectionViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: Lets and Vars
    // Statics
    static private var shared: DestinationSelectionViewController?

    // Public
    class func destinationAirport()
        -> AirportDatabase.Airport? {
            let destinationAirport = shared?.selectedDestinationAirport
            return destinationAirport
    }

    // Private

    // Datasource
    private var selectedDestinationAirport: AirportDatabase.Airport?
    private var formerSelectedDestinationAirport: AirportDatabase.Airport?

    private var destinationAirportArray = [AirportDatabase.Airport]()
    private var sortSwitchIndex = 0
    
    // Notification Observers
    private var airportUpdateCompletedNotification: NSObjectProtocol?
    private var airportUpdateFailedNotification: NSObjectProtocol?
    
    // Pull to Refresh of TableView
    private let refreshControl = UIRefreshControl()
    
    // MARK: - IBOutlets
    @IBOutlet weak private var countryImageTop: UIImageView!
    @IBOutlet weak private var airportName: UILabel!
    @IBOutlet weak private var airportInfoButton: UIButton!
    @IBOutlet weak private var airportsSortedBySwitch: UISegmentedControl!
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var tableView: UITableView!
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        DestinationSelectionViewController.shared = self
        
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

        setupTableViewDatasource()
        
        updateUIForSelectedDestinationAirport()
        searchBar.placeholder = "Filter Airfields"
        
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
    
    // Remove Obeservers when View did Disappear
    override func viewDidDisappear(_ animated: Bool) {
        if let airportUpdateCompletedNotification = airportUpdateCompletedNotification {
            NotificationCenter.default.removeObserver(airportUpdateCompletedNotification)
        }
        
        if let airportUpdateFailedNotification = airportUpdateFailedNotification {
            NotificationCenter.default.removeObserver(airportUpdateFailedNotification)
        }
    }

    // MARK: - Public Class Methods
    class func distanceToDestinationAirport()
        -> CLLocationDistance? {
            guard let selectedDestinationAirport = shared?.selectedDestinationAirport
                else { return nil }

            let destinationAirportLocation = CLLocation(latitude: selectedDestinationAirport.latitude,
                                                        longitude: selectedDestinationAirport.longitude)
            let distanceToDestinationAirport = LocationManager.distanceFromCurrentLocationTo(location: destinationAirportLocation)

            return distanceToDestinationAirport
    }



    // MARK: - Private Instance Methods
    // updateUIForSelectedDestinationAirport
    private func updateUIForSelectedDestinationAirport() {
        if let destinationAirport = self.selectedDestinationAirport {
            countryImageTop.image = UIImage(named: destinationAirport.country!)
            airportName.text = destinationAirport.name
            airportInfoButton.isHidden = false
        } else {
            countryImageTop.image = UIImage(named: "destination")
            airportName.text = "Choose your Destination"
            airportInfoButton.isHidden = true
        }
    }
    
    // Setup TableViewDatasource
    private func setupTableViewDatasource() {
        guard let sortIndicator = AirportDatabase.SortIndicator(rawValue: airportsSortedBySwitch.selectedSegmentIndex)
            else { fatalError("segmentIndex not suitable for sortIndicator.")}
        
        if let destinationAirportArray = AirportDatabase.filteredDestinationAirports(byName: searchBar.text,
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
            self.present(mailComposer, animated: true,
                         completion: nil)
        } else {
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
        selectedDestinationAirport = nil
        
        AirportDatabase.downloadAirportsFromServer()
    }
    
    // Adjust TableView height if necessary
    @objc private func adjustForKeyboard(notification: Notification) {
        
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
    @IBAction func sortSwitchAction(_ sender: UISegmentedControl) {
        setupTableViewDatasource()
    }
    
    // Report missing Airport Button
    @IBAction func reportMissingAirportAction(_ sender: UIButton) {
        reportMissingAirport()
    }
    
    // Airport Info Button
    @IBAction func airportInfoButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "AirportInfoSegue", sender: self)
    }
    
}

// MARK: - Extension - UITableViewDataSource
extension DestinationSelectionViewController: UITableViewDataSource {
    
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
            
            // Get Cell from TableView
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DestinationSelectionAirportTableViewCell.identifier) as? DestinationSelectionAirportTableViewCell
                else { fatalError("")}
            
            let airportOfInterest = destinationAirportArray[indexPath.row]
            
            // Texts in Cell
            cell.airportNameLabel.text = airportOfInterest.name
            cell.icaoLabel.text = airportOfInterest.icao
            cell.distanceLabel.text = distanceAsReadable(airportOfInterest.distance)
            
            var countryImage = UIImage.init(named: "destination")
            if let country = airportOfInterest.country {
                countryImage = UIImage.init(named: country)
            }
            cell.countryImageView.image = countryImage
            
            // Set Checkmark and Background Color for selected Airport
            if selectedDestinationAirport?.latitude == airportOfInterest.latitude,
                selectedDestinationAirport?.longitude == airportOfInterest.longitude {
                cell.accessoryType = .checkmark
                cell.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 255/255, alpha: 1.0)
            } else {
                cell.accessoryType = .none
                cell.backgroundColor = nil
            }
            
            return cell
    }
    
}

// MARK: - Extension - UITableViewDelegate
extension DestinationSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let newSelectedDestinationAirport = destinationAirportArray[indexPath.row]
        
        // If the newly selected destination equals the former:
        // it means we want to cancel the navigation
        // We deselect the active cell and set selectedDestinationAirport = nil

        if let formerSelectedDestinationAirport = self.formerSelectedDestinationAirport,
            newSelectedDestinationAirport.latitude == formerSelectedDestinationAirport.latitude
                && newSelectedDestinationAirport.longitude == formerSelectedDestinationAirport.longitude {
            selectedDestinationAirport = nil
            self.formerSelectedDestinationAirport = nil
        } else {
            selectedDestinationAirport = newSelectedDestinationAirport
            formerSelectedDestinationAirport = newSelectedDestinationAirport
        }
        
        updateUIForSelectedDestinationAirport()
        
        guard let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows
            else { return }
        tableView.reloadRows(at: indexPathsForVisibleRows, with: .none)
    }
    
}

// MARK: - Extension - UISearchBarDelegate
extension DestinationSelectionViewController: UISearchBarDelegate {
    
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
