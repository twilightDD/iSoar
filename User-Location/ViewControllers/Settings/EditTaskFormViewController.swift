//
//  EditTaskFormViewController.swift
//  Glider Tool
//
//  Created by sonic on 11.01.21.
//  Copyright © 2021 Denis Leupold. All rights reserved.
//

import Eureka
import CoreData

class EditTaskFormViewController: FormViewController {
    
    // MARK: - Lets and Vars
    private var _task: Task?
    var task: Task {
        get {
            if let storedTask = _task {
                return storedTask
            } else {
                let newTask = Task.init(context: editContext)
                _task = newTask
                return newTask
            }
        }
        set {
            guard let taskInEditContext = editContext.object(with: newValue.objectID) as? Task
            else { fatalError() }
            _task = taskInEditContext
        }
    }
    
    private let editContext = CoreDataManager.editContextForUI()
    
    // MARK: IBOutlets
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Task Details"
        tableView.isEditing = true
        
        form.append(taskNameSection())
        form.append(taskEntriesSection())
        
    }
    
    // TODO: 20210212 .Reorder einbinden
    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        
        print("REORDER CAPTURED")
        
    }
    
    private func textColor()
    -> UIColor {
        var textColor: UIColor = .black
        
        if self.traitCollection.userInterfaceStyle == .light {
            textColor = .black
        } else {
            textColor = .white
        }
        return textColor
    }
    
    // MARK: - Private Methods
    // MARK: Eureka Form Sections
    private func taskNameSection()
    -> Section {
        let section = Section("Task Name")
        section.tag = "Task Name"
        
        section
            <<< TextRow { row in
                row.title = "Task Name"
                row.value = self.task.taskName
                row.placeholder = "Task Name"
                row.add(rule: RuleRequired())
                row.add(rule: RuleMinLength(minLength: 3))
                row.validationOptions = .validatesOnChange
                
            }.cellUpdate { cell, row in
                self.validateForm()
                if row.isValid == false {
                    cell.titleLabel?.textColor = .red
                }
                
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(systemName: "textformat")
            }.onChange({ [unowned self] row in
                if let taskname = row.value {
                    self.task.taskName = taskname
                } else {
                    self.task.taskName = ""
                }
                
            })
        
        return section
    }
    
    private func taskEntriesSection()
    -> Section {
        
        // TODO: 20210212 .Reorder einbinden
        MultivaluedSection(multivaluedOptions: [.Delete, .Insert],
                           header: "Waypoints") {
            
            let allAirports = editContext.fetchObjects(forEntityClass: Airport.self,
                                                       sortByKeypath: Airport.Attributes.name)
            
            $0.tag = "Waypoints"
            
            if let waypointsInTask = self.task.waypoints {
                
                for case let waypoint in waypointsInTask {
                    
                    let deleteAction = SwipeAction(style: .destructive,
                                                   title: "Delete") { (action, row, completionHandler) in
                        self.task.removeFromWaypoints(waypoint)
                        completionHandler?(true)
                    }
                    
                    $0 <<< PushRow<Airport> { row in
                        row.tag = "\(String(describing: waypoint.uuid))"
                        row.value = waypoint.airport
                        row.options = allAirports
                        row.displayValueFor = { airport in
                            if airport != nil {
                                return airport?.name
                            } else {
                                return ""
                            }
                        }
                        
                        row.trailingSwipe.actions = [deleteAction]
                        
                    }.onPresent { from, row in
                        row.selectableRowCellUpdate = { (cell, row) in
                            cell.imageView?.image = UIImage(systemName: "arrow.uturn.down")
                            
                        }
                        
                    }.onChange { row in
                        waypoint.airport = row.value
                        
                    }
                    
                }
                
            }
            
            $0.multivaluedRowToInsertAt = { index in
                
                let waypoint = Waypoint(context: self.editContext)
                waypoint.uuid = UUID()
                waypoint.task = self.task
                
                return PushRow<Airport> { row in
                    row.tag = "\(index)"
                    row.options = allAirports
                    row.displayValueFor = { airport in
                        if airport != nil {
                            return airport?.name
                        } else {
                            return ""
                        }
                    }
                    
                }.onPresent { from, row in
                    row.selectableRowCellUpdate = { (cell, row) in
                        cell.imageView?.image = UIImage(systemName: "arrow.uturn.down")
                        
                    }
                    
                }.onChange { row in
                    waypoint.airport = row.value
                    
                }
                
            }
            
        }
        
    }
    
    private func validateForm() {
        let validationErrors = form.validate()
        if validationErrors.isEmpty == true {
            saveBarButtonItem.isEnabled = true
        } else {
            saveBarButtonItem.isEnabled = false
        }
    }
    
    // MARK: - Action Methods
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtontapped(_ sender: UIBarButtonItem) {
        guard let taskName = task.taskName
        else { fatalError("Save Button tapped while TaskName or UUID is nil") }
        
        let existingTasks = Task.fetchTasks(taskName: taskName,
                                            context: editContext)
        
        if existingTasks.count == 1 {
            editContext.saveContext()
            self.dismiss(animated: true, completion: nil)
        } else if existingTasks.isEmpty == true {
            fatalError("ich muss self.task haben.")
        } else {
            DLAlertViewController.showAlertViewController(title: "Warning",
                                                          message: "Task Name already exists.",
                                                          preferredStyle: .alert,
                                                          on: self)
            
        }
        
    }
    
}
