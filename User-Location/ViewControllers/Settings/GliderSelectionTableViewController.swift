//
//  GliderSelectionViewController.swift
//  Glider Tool
//
//  Created by sonic on 25.06.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import UIKit
import CoreData

class GliderSelectionTableViewController: UITableViewController {
    
    // MARK: - Keys
    private static let GliderSelectionTableViewCellIdentifierKey = "GliderSelectionTableViewCellIdentifier"
    private static let OpenEditGliderFormViewControllerSegueKey = "OpenEditGliderFormViewControllerSegue"
    
    // MARK: - Lets and Vars
    private lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = setupFetchedResultsController()
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Glider Selection"
        
    }
    
    // Segue Handling
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == GliderSelectionTableViewController.OpenEditGliderFormViewControllerSegueKey {
            if let glider = sender as? Glider {
                guard let navController = segue.destination as? UINavigationController
                    else { fatalError("Must be an UINavigationController.") }
                guard let editGliderViewController = navController.children[0] as? EditGliderFormViewController
                    else { fatalError("Must be an EditGliderFormViewController.") }
                editGliderViewController.glider = glider
            }
        }
        
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController()
        -> NSFetchedResultsController<NSFetchRequestResult> {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Glider")
            let sortDesc = NSSortDescriptor(key: "registration", ascending: true)
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
extension GliderSelectionTableViewController {
    
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
            let cell = tableView.dequeueReusableCell(withIdentifier: GliderSelectionTableViewController.GliderSelectionTableViewCellIdentifierKey,
                                                     for: indexPath)
            
            // Set up the cell
            guard let glider = self.fetchedResultsController.object(at: indexPath) as? Glider
                else { fatalError("Attempt to configure cell without a managed object") }
            
            //Populate the cell from the object
            cell.imageView?.image = UIImage(systemName: "airplane")
            cell.textLabel?.text = glider.registration
            
            // Set Checkmark for selected Glider
            if glider.registration == UserDefaultsManager.gliderID() {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
    }
    
    // User didSelect Row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let glider = self.fetchedResultsController.object(at: indexPath) as? Glider
            else { fatalError("Attempt to configure cell without a managed object") }
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        UserDefaultsManager.set(gliderID: glider.registration!)
        UserDefaultsManager.set(gliderRatio: glider.ratio)
        UserDefaultsManager.set(ownFlarmID: glider.flarmID!)
        
        tableView.reloadData()
        
    }
    
    // Delete Glider via Swipe to left
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
                
                guard let glider = self.fetchedResultsController.object(at: indexPath) as? Glider
                    else { fatalError("Attempt to configure cell without a managed object") }

                let editContext = CoreDataManager.editContextForUI()
                let gliderInEditContext = editContext.object(with: glider.objectID)
                editContext.delete(gliderInEditContext)
                editContext.saveContext()
            }
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
    }
    
    // Edit Glider via Swipe to right
    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
            let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, complete in
                
                guard let glider = self.fetchedResultsController.object(at: indexPath) as? Glider
                    else { fatalError("Attempt to configure cell without a managed object") }
                
                self.performSegue(withIdentifier: GliderSelectionTableViewController.OpenEditGliderFormViewControllerSegueKey,
                                  sender: glider)
                
            }
            
            let configuration = UISwipeActionsConfiguration(actions: [editAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
            
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension GliderSelectionTableViewController: NSFetchedResultsControllerDelegate {
    
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
