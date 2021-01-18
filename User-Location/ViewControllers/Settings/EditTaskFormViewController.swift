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
                self.task.taskName = row.value
            })
        
        return section
    }
    
    private func taskEntriesSection()
    -> Section {
        
        MultivaluedSection(multivaluedOptions: [.Delete, .Insert, .Reorder],
                           header: "Waypoints") {
            
            let allAirportNames = editContext.fetchObjects(forEntityClass: Airport.self,
                                                           sortByKeypath: Airport.Attributes.name)
            
            $0.tag = "Waypoints"
            
            $0.multivaluedRowToInsertAt = { index in
                return PushRow<Airport> { row in
                    row.title = "Turn \(index)"
                    row.tag = "\(index)"
                    row.options = allAirportNames
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

                }
            
            }
            
            $0 <<< PushRow<Airport> { row in
                row.title = "Start"
                row.tag = "\(index)"
                row.options = allAirportNames
                row.displayValueFor = { airport in
                    if airport != nil {
                        return airport?.name
                    } else {
                        return ""
                    }
                }
                
            }.onPresent { from, row in
                row.selectableRowCellUpdate = { (cell, row) in
                    cell.imageView?.image = UIImage(systemName: "arrow.up")
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
        
        else { fatalError("Save Button tapped while TaskName is nil") }
        
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
        
        //let values = (self.form.values()["Waypoints"]!! as! [Airport?]).compactMap { $0 }
        //let values = self.form.values()
        //print(values)
        
    }

}
