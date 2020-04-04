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
    private var gpxFileNames = [String]()
    private var selectedGPXFileName: String?
    
    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    
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
        gpxFileNames = TasksDatabase.gpxFileNames()
        
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
            let numberOfRowsInSection = gpxFileNames.count
            return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            // Get Cell from TableView
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskSelectionTableViewCell.identifier) as? TaskSelectionTableViewCell
                else { fatalError("")}
            
            let gpxFileNameOfInterest = gpxFileNames[indexPath.row]
            
            // Texts in Cell
            cell.taskName.text = gpxFileNameOfInterest
            
            if gpxFileNameOfInterest == selectedGPXFileName {
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
extension TasksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newSelectedGPXFileName = gpxFileNames[indexPath.row]
        
        // If the newly selected task equals the former:
        // it means we want to cancel the task
        // We deselect the active cell and set selectedGPXFileName = nil
        if newSelectedGPXFileName == self.selectedGPXFileName {
            self.selectedGPXFileName = nil
            TasksDatabase.noGPXFileSelected()
        } else {
            self.selectedGPXFileName = newSelectedGPXFileName
            TasksDatabase.openGPXFile(withFilename: newSelectedGPXFileName)
        }
        
        guard let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows
            else { return }
        tableView.reloadRows(at: indexPathsForVisibleRows, with: .none)
    }
    
}
