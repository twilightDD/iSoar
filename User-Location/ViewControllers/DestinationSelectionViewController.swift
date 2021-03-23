//
//  DestinationSelectionViewController.swift
//  Glider Tool
//
//  Created by sonic on 21.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class DestinationSelectionViewController: UIViewController {

    // MARK: Lets and Vars
    // Statics
    static private var shared: DestinationSelectionViewController?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = setupFetchedResultsController()

    // Notification Observers
    private var airportImportOrUpdateFinishedNotification: NSObjectProtocol?
    private var airportImportOrUpdateFailedNotification: NSObjectProtocol?
    
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

        tableView.reloadData()
        
        updateUIForSelectedDestinationAirport()
        updateSearchbarPlaceholder()
        
        // MARK: - Register Observers for notfications
        // Airport Update Finished
        airportImportOrUpdateFinishedNotification = NotificationCenter.default.addObserver(forName: Airport.importOrUpdateFinishedNotification,
                                                                                   object: nil,
                                                                                   queue: OperationQueue.main) { [unowned self] (notification) in
            
            self.updateUIForSelectedDestinationAirport()
            self.refreshControl.endRefreshing()
            NotificationBanner.show("Airport Database updated")

        }

        // TODO: 20210107 Airport Update Failed Notification
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Remove Obeservers when View did Disappear
        if let airportImportOrUpdateFinishedNotification = airportImportOrUpdateFinishedNotification {
            NotificationCenter.default.removeObserver(airportImportOrUpdateFinishedNotification)
        }
        
        if let airportImportOrUpdateFailedNotification = airportImportOrUpdateFailedNotification {
            NotificationCenter.default.removeObserver(airportImportOrUpdateFailedNotification)
        }

    }

    // MARK: - Public Class Methods

    // MARK: - Private Methods
    private func setupFetchedResultsController()
    -> NSFetchedResultsController<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Airport.entityName())
        let sortDesc = NSSortDescriptor(key: Airport.Attributes.name,
                                        ascending: true,
                                        selector: #selector(NSString.localizedCompare(_:)))
        request.sortDescriptors = [sortDesc]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                  managedObjectContext: CoreDataManager.viewOnlyContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        return fetchedResultsController
    }

    // updateUIForSelectedDestinationAirport
    private func updateUIForSelectedDestinationAirport() {
        if let destinationAirport = FlightComputer.selectedDestinationAirport() {
            airportName.text = destinationAirport.name
            airportInfoButton.isHidden = false
            countryImageTop.image = destinationAirport.countryImage()
        } else {
            airportName.text = "Choose your Destination"
            airportInfoButton.isHidden = true
            countryImageTop.image = UIImage(named: "destination")
        }
    }
    
    private func updateSearchbarPlaceholder() {
        searchBar.placeholder = "Search in \(fetchedResultsController.fetchedObjects?.count ?? 0) Airfields"
    }

    private func distanceAsReadable(_ distance: CLLocationDistance?)
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

        DLDownloadManager.download(.airports,
                                   completion: { data in

                                    guard let data = data
                                    else {
                                        //NotificationBanner.show("No data received.")
                                        return
                                    }

                                    // TODO: 20201207 Success zurückwerfen
                                    CoreDataImporter.importData(data, forType: .airports)

                                   })
        
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
        var sortDescriptor: NSSortDescriptor!
        
        switch sender.selectedSegmentIndex {
        case 0: // sort by name
            sortDescriptor = NSSortDescriptor(key: Airport.Attributes.name,
                                              ascending: true,
                                              selector: #selector(NSString.localizedCompare(_:)))
        case 1:  // sort by distance
            sortDescriptor = NSSortDescriptor(key: Airport.Attributes.distance,
                                              ascending: true)
        default:
            fatalError()
        }
        
        fetchedResultsController.fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        tableView.reloadData()
        
    }
       
}

// MARK: - Extension - UITableViewDelegate
extension DestinationSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let airport = self.fetchedResultsController.object(at: indexPath) as? Airport
        else { fatalError("No airport for indexPath.") }
        
        if FlightComputer.selectedDestinationAirport() == airport {
            FlightComputer.setSelectedDestinationAirport(nil)
        } else {
            let newSelectedDestinationAirport = airport
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            fetchedResultsController.fetchRequest.predicate = nil
        } else {
            let predicate1 = NSPredicate(format: "%K CONTAINS[c] %@",
                                         argumentArray: [Airport.Attributes.name, searchText])
            let predicate2 = NSPredicate(format: "%K CONTAINS[c] %@",
                                         argumentArray: [Airport.Attributes.icao, searchText])
            
            let compoundPredicate = NSCompoundPredicate(type: .or,
                                                        subpredicates: [predicate1, predicate2])
            
            fetchedResultsController.fetchRequest.predicate = compoundPredicate
            
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = nil

        // TODO: 20201222 das könnte doch über einen UISearchController laufen
        fetchedResultsController.fetchRequest.predicate = nil
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension DestinationSelectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //print("\(#function)")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        @unknown default:
            fatalError("Error")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            break
            // TODO: 20210308: We have to ignore the update case, because we are updating AND moving the Cells at the same time.
            // Workaround could be: Dispatch async. But maybe there is a better way...
            //tableView.reloadRows(at: [indexPath!], with: .fade)
        @unknown default:
            fatalError("Error")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        // TODO: 20210308: So we have to handle the Cell Updates afterwards
        DispatchQueue.main.async {
            if let visibleRows = self.tableView.indexPathsForVisibleRows {
                self.tableView.reloadRows(at: visibleRows, with: .fade)
            }
        }
        
        updateSearchbarPlaceholder()
    }
}

// MARK: - UITableViewDataSource
extension DestinationSelectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView)
        -> Int {
            return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
            guard let sections = fetchedResultsController.sections else {
                fatalError("No sections in fetchedResultsController")
            }
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        
        // Get Cell from TableView
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DestinationSelectionAirportTableViewCell.identifier) as? DestinationSelectionAirportTableViewCell
        else { fatalError("")}
        
        // Set up the cell
        guard let airport = self.fetchedResultsController.object(at: indexPath) as? Airport
        else { fatalError("Attempt to configure cell without a managed object") }
        
        // Populate the cell from the object
        cell.airportNameLabel.text = airport.name
        cell.icaoLabel.text = airport.icao
        cell.distanceLabel.text = distanceAsReadable(airport.distance)
        cell.countryImageView.image = airport.countryImage()
        
        // Set Checkmark for selected Row
        if FlightComputer.selectedDestinationAirport() == airport {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }

}
