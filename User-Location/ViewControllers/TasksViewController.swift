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
            
            // get cell from tableView
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskSelectionTableViewCell.identifier) as? TaskSelectionTableViewCell
                else { fatalError("")}

            let taskOfInterest = tasksArray[indexPath.row]

            cell.taskName.text = taskOfInterest
            
            return cell
    }
    
}

//MARK: - Extension - UITableViewDelegate
extension TasksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
