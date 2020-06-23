//
//  DestinationSelectionViewController.swift
//  Glider Tool
//
//  Created by sonic on 21.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit
import CoreLocation

class DestinationSelectionViewController: UIViewController {
    
    // MARK: Lets and Vars
    // Statics
    static private var shared: DestinationSelectionViewController?
    
    private var destinationAirportArray = [AirportDatabase.Airport]()
    private var sortSwitchIndex = 0
    
    // Notification Observers
    private var airportUpdateCompletedNotification: NSObjectProtocol?
    private var airportUpdateFailedNotification: NSObjectProtocol?
    
    // Pull to Refresh of TableView
    private let refreshControl = UIRefreshControl()
    
    private var selectedIndexPath: IndexPath?
    
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
        searchBar.placeholder = "Search in \(self.destinationAirportArray.count) Airfields"
        
        // MARK: - Register Observers for notfications
        // Airport Update Completed
        airportUpdateCompletedNotification = NotificationCenter.default
            .addObserver(forName: AirportDatabase.airportUpdateCompletedNotificationName,
                         object: nil,
                         queue: OperationQueue.main) { [unowned self] (notification) in
                            
                            self.updateUIForSelectedDestinationAirport()
                            self.setupTableViewDatasource()
                            self.refreshControl.endRefreshing()
                            self.searchBar.placeholder = "Search in \(self.destinationAirportArray.count) Airfields"
        }
        
        // Airport Update Failed
        airportUpdateFailedNotification = NotificationCenter.default
            .addObserver(forName: AirportDatabase.airportUpdateFailedNotificationName,
                         object: nil,
                         queue: OperationQueue.main) { [unowned self] (notification) in
                            
                            self.refreshControl.endRefreshing()
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
            guard let selectedDestinationAirport = FlightComputer.selectedDestinationAirport()
                else { return nil }

            let destinationAirportLocation = CLLocation(latitude: selectedDestinationAirport.latitude,
                                                        longitude: selectedDestinationAirport.longitude)
            let distanceToDestinationAirport = LocationManager.distanceFromCurrentLocationTo(location: destinationAirportLocation)

            return distanceToDestinationAirport
    }

    // MARK: - Private Methods
    // updateUIForSelectedDestinationAirport
    private func updateUIForSelectedDestinationAirport() {
        if let destinationAirport = FlightComputer.selectedDestinationAirport() {
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
        FlightComputer.setSelectedDestinationAirport(nil)
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
            if FlightComputer.selectedDestinationAirport() == airportOfInterest {
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
        
        if FlightComputer.selectedDestinationAirport() == destinationAirportArray[indexPath.row] {
            FlightComputer.setSelectedDestinationAirport(nil)
        } else {
            let newSelectedDestinationAirport = destinationAirportArray[indexPath.row]
            FlightComputer.setSelectedDestinationAirport(newSelectedDestinationAirport)
        }

        updateUIForSelectedDestinationAirport()
        
        guard let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows
            else { return }
        tableView.reloadRows(at: indexPathsForVisibleRows, with: .none)
        
        // Dismiss Keyboard when Airport is selected
        searchBar.resignFirstResponder()
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
