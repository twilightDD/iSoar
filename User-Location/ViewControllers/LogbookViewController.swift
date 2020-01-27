//
//  Logbook.swift
//  Glider Tool
//
//  Created by sonic on 28.10.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class LogbookViewController: UIViewController {
    
    // MARK: Lets and Vars
    // Datasource
    // ToDo: Source!
    var flightMetaDatas = [FlightMetaData]()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!


    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTableViewDatasource()
    }


    //MARK -  TableViewDatasource
    private func setupTableViewDatasource() {
        flightMetaDatas = FlightsDatabase.flightMetaDatas()

        tableView.reloadData()
    }

}

// MARK: - Extension - UITableViewDataSource
extension LogbookViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView)
        -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
            let numberOfRowsInSection = flightMetaDatas.count
            return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            // get cell from tableView
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FlightSelectionTableViewCell.identifier) as? FlightSelectionTableViewCell
                else { fatalError("")}
            
            let flightMetaDataOfInterest = flightMetaDatas[indexPath.row]
            
            cell.flightDate.text = flightMetaDataOfInterest.flightDate
            cell.gliderID.text = flightMetaDataOfInterest.gliderID
            cell.startTime.text = flightMetaDataOfInterest.startTimeUTC
            cell.startICAO.text = flightMetaDataOfInterest.startICAO
            cell.endTime.text = flightMetaDataOfInterest.endTimeUTC
            cell.endICAO.text = flightMetaDataOfInterest.endICAO
            cell.flightTime.text = flightMetaDataOfInterest.flightTime
            
            return cell
    }
    
}

//MARK: - Extension - UITableViewDelegate
extension LogbookViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
