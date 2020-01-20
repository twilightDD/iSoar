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
    var flightsArray = [String]()
    
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
    
    // Setup TableViewDatasource
    private func setupTableViewDatasource() {
        flightsArray = FlightsDatabase.flightFileNames().sorted(by: {$0.description > $1.description})
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
            let numberOfRowsInSection = flightsArray.count
            return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            // get cell from tableView
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FlightSelectionTableViewCell.identifier) as? FlightSelectionTableViewCell
                else { fatalError("")}
            
            let flightOfInterest = flightsArray[indexPath.row]
            
            cell.flightName.text = flightOfInterest
            
            return cell
    }
    
}

//MARK: - Extension - UITableViewDelegate
extension LogbookViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
