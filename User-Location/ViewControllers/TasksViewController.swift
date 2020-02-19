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
    var tasksArray = [String]()
    
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
    
    // MARK: - Private Methods
    // Setup TableViewDatasource
    private func setupTableViewDatasource() {
        tasksArray = TasksDatabase.gpxFileNames()
        
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
            
            // Get Cell from TableView
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskSelectionTableViewCell.identifier) as? TaskSelectionTableViewCell
                else { fatalError("")}
            
            let taskOfInterest = tasksArray[indexPath.row]
            
            // Texts in Cell
            cell.taskName.text = taskOfInterest
            
            // TODO: Set Checkmark and Background Color for selected Task
            if taskOfInterest == nil {
                cell.accessoryType = .checkmark
                cell.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 255/255, alpha: 1.0)
            } else {
                cell.accessoryType = .none
                cell.backgroundColor = nil
            }
            
            return cell
            
            // Ausgabe des Tasks VC
            //    wenn zelle getippt
            //    markiere zelle mit checkmark und hintergrundfarbe
            
            // Aufgabe der TasksDatabase
            //      currentTaskWaypointCoordinates = nil
            //    greife auf hinterlegte .gpx zu
            //    parse diese nach waypoints (xml parser)
            //    füge diese waypoints in ein array ein

            // Aufgabe des MapScreen - MapScreen.shared?.drawTaskLines()
            // mapView.removeAnnotation(currentTaskLine) - läuft
            // mapView.addAnnotation(currentTaskLine) - läuft
            
            //    wenn zelle nochmals getippt
            //    remove polyline / set task = nil
            
    }
    
}

// MARK: - Extension - UITableViewDelegate
extension TasksViewController: UITableViewDelegate {
    // Cell selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Draw Polylines between Task Coordinates
        MapScreen.shared?.drawTaskLines()
    }
}
