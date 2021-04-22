//
//  TaskSelectionTableViewController.swift
//  Glider Tool
//
//  Created by sonic on 11.01.21.
//  Copyright © 2021 Denis Leupold. All rights reserved.
//

import UIKit
import CoreData

protocol TaskSelectionProtocol: AnyObject {
    func setNewTask(coordinates: [CLLocationCoordinate2D])

}

class TaskSelectionTableViewController: UITableViewController {

    // MARK: - Keys
    private static let TaskSelectionTableViewCellIdentifierKey = "TaskSelectionTableViewCellIdentifier"
    private static let OpenEditTaskFormViewControllerSegueKey = "OpenEditTaskFormViewControllerSegue"

    // MARK: - Lets and Vars
    // Static
    private static let shared = TaskSelectionTableViewController()

    // Public
    weak var taskSelectionDelegate: TaskSelectionProtocol?

    // Private
    private var taskWaypoints = [CLLocationCoordinate2D]()

    private lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = setupFetchedResultsController()

    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Task Selection"
    }

    // Segue Handling
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TaskSelectionTableViewController.OpenEditTaskFormViewControllerSegueKey {
            if let task = sender as? Task {
                guard let navController = segue.destination as? UINavigationController
                    else { fatalError("Must be an UINavigationController.") }
                guard let editTaskViewController = navController.children[0] as? EditTaskFormViewController
                    else { fatalError("Must be an EditTaskFormViewController.") }
                editTaskViewController.task = task
            }
        }

    }

    // MARK: - Public Class Methods
    class func registerForTaskUpdates(_ delegate: TaskSelectionProtocol) {
        shared.taskSelectionDelegate = delegate
    }

    class func unRegisterForTaskUpdates() {
        shared.taskSelectionDelegate = nil
    }

    // MARK: - Private Methods
    private func setupFetchedResultsController()
        -> NSFetchedResultsController<NSFetchRequestResult> {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
            let sortDesc = NSSortDescriptor(key: "taskName", ascending: true)
            request.sortDescriptors = [sortDesc]

            let fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                  managedObjectContext: CoreDataManager.viewOnlyContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
            fetchedResultsController.delegate = self

            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }

            return fetchedResultsController
    }

}

// MARK: - TableView Content
extension TaskSelectionTableViewController {

    override func numberOfSections(in tableView: UITableView)
        -> Int {
            return fetchedResultsController.sections!.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
            guard let sections = fetchedResultsController.sections else {
                fatalError("No sections in fetchedResultsController")
            }
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskSelectionTableViewController.TaskSelectionTableViewCellIdentifierKey,
                                                     for: indexPath)

            // Set up the cell
            guard let task = self.fetchedResultsController.object(at: indexPath) as? Task
                else { fatalError("Attempt to configure cell without a managed object") }

            //Populate the cell from the object
            cell.imageView?.image = UIImage(systemName: "doc.text")
            cell.textLabel?.text = String(task.taskName ?? "")

        // Set Checkmark for selected Row
        if FlightComputer.selectedTask() == task {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none

        }

            return cell
    }

    // User didSelect Row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedTask = self.fetchedResultsController.object(at: indexPath) as? Task
            else { fatalError("Attempt to configure cell without a managed object") }

        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

        // If selected Task is the same Task which is already selected
        if FlightComputer.selectedTask() == selectedTask {
            FlightComputer.setSelectedTask(nil)
            taskWaypoints.removeAll()

            // Inform Delegate
            TaskSelectionTableViewController.shared.taskSelectionDelegate?.setNewTask(coordinates: taskWaypoints)

            // If selected Task is NOT the same Task which is already selected
        } else {
            let newSelectedTask = selectedTask
            taskWaypoints.removeAll()
            FlightComputer.setSelectedTask(newSelectedTask)

            if let waypointsInTask = selectedTask.waypoints {
                for waypoint in waypointsInTask {
                    if let airportLocationCoordinate2D = waypoint.airport?.locationCoordinate2D {
                        taskWaypoints.append(airportLocationCoordinate2D)
                    }

                }

            }

            // Inform Delegate
            TaskSelectionTableViewController.shared.taskSelectionDelegate?.setNewTask(coordinates: taskWaypoints)

        }

        tableView.reloadData()

    }

    // Delete Task via Swipe to left
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in

                guard let task = self.fetchedResultsController.object(at: indexPath) as? Task
                    else { fatalError("Attempt to configure cell without a managed object") }

                let editContext = CoreDataManager.editContextForUI()
                let taskInEditContext = editContext.object(with: task.objectID)
                editContext.delete(taskInEditContext)
                editContext.saveContext()
            }

            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration

    }

    // Edit Task via Swipe to right
    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
            let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, complete in

                guard let task = self.fetchedResultsController.object(at: indexPath) as? Task
                    else { fatalError("Attempt to configure cell without a managed object") }

                self.performSegue(withIdentifier: TaskSelectionTableViewController.OpenEditTaskFormViewControllerSegueKey,
                                  sender: task)

            }

            let configuration = UISwipeActionsConfiguration(actions: [editAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration

    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TaskSelectionTableViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        @unknown default:
            fatalError("Error")
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError("Error")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
