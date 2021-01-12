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
    
    // MARK: - Keys
    static let TaskNameKey = "TaskName"

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
            guard let gliderInEditContext = editContext.object(with: newValue.objectID) as? Task
            else { fatalError() }
            _task = gliderInEditContext
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
        
        MultivaluedSection(multivaluedOptions: [.Insert, .Delete, .Reorder],
                           header: "Waypoints") { row in
            
            let allAirportNames = editContext.fetchObjects(forEntityClass: Airport.self,
                                                           sortByKeypath: Airport.Attributes.name)

            row.tag = "Task Entries"
            row.multivaluedRowToInsertAt = { index in
                return PushRow<Airport> { row in
                    row.title = "Turn \(index)"
                    row.options = allAirportNames
                    row.displayValueFor = { airport in
                        if airport != nil {
                            return airport?.name
                        } else {
                            return ""
                        }
                    }
                }
            }
            row <<< PushRow<Airport> { row in
                row.title = "Start"
                row.options = allAirportNames
                row.displayValueFor = { airport in
                    if airport != nil {
                        return airport?.name
                    } else {
                        return ""
                    }
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
        
        let existingTasks = Task.fetchTaskss(taskName: taskName, context: editContext)
        
        if existingTasks.count == 1 {
            editContext.saveContext()
            self.dismiss(animated: true, completion: nil)
        } else if existingTasks.isEmpty == true {
            fatalError("ich muss self.glider haben.")
        } else {
            let alertViewController = UIAlertController.init(title: "Warning",
                                                             message: "Task-Name already exists.",
                                                             preferredStyle: .alert)
            
            let cancelAction = UIAlertAction.init(title: "OK",
                                                  style: .cancel) { (action) in
            }
            
            alertViewController.addAction(cancelAction)
            present(alertViewController, animated: true) {
                
            }
        }
        
    }

}
