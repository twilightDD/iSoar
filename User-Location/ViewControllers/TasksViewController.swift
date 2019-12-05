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
    
    // MARK: - IBOutlets
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForTasksFolder()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Private Functions
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
}
