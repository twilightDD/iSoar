//
//  TasksViewController.swift
//  Glider Tool
//
//  Created by sonic on 05.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class TasksViewController: UIViewController {
    
    // MARK: Lets and Vars
    // Datasource
    // ToDo: Source!
    var tasksArray = [AirportDatabase.Airport]()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForTasksFolder()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTableViewDatasource()
        
    }
    
    // MARK: - Private Methods
    // Check for Tasks Folder inside the Documetns Folder
    private func checkForTasksFolder () {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent("Tasks")
        if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
            print("Tasks Folder dont exist in Documents Folder. Creating...")
            do {
                try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        else {
            print("Tasks Folder exist in Documents Folder.")
        }
    }
    
    // Setup TableViewDatasource
    private func setupTableViewDatasource() {
        
        
        
        tableView.reloadData()
    }
}


// MARK: - Extension - UITableViewDataSource
extension TasksViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView)
        -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
            let numberOfRowsInSection = tasksArray.count
            return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            // get cell from tableView
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskSelectionTableViewCell.identifier) as? TaskSelectionTableViewCell
                else { fatalError("")}
            
            let airportOfInterest = tasksArray[indexPath.row]
            
            // texts in cell
            // ToDo: source!
            cell.taskName.text = airportOfInterest.name
            
            // checkbox for selected airport
            if MapScreen.shared!.selectedDestinationAirport?.icao == airportOfInterest.icao {
                cell.accessoryType = .checkmark
                cell.backgroundColor = UIColor(red: 17/255, green: 113/255, blue: 255/255, alpha: 0.1)
            }
            else {
                cell.accessoryType = .none
                cell.backgroundColor = nil
            }
            
            return cell
    }
    
}

//MARK: - Extension - UITableViewDelegate
extension TasksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
