//
//  BuddyListTableViewController.swift
//  Glider Tool
//
//  Created by sonic on 02.08.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import UIKit
import CoreData

class BuddyListTableViewController: UITableViewController {
    
        // MARK: - Keys
        private static let BuddyListTableViewCellIdentifierKey = "BuddyListTableViewCellIdentifier"
        private static let OpenEditBuddyFormViewControllerSegueKey = "OpenEditBuddyFormViewControllerSegue"
        
        // MARK: - Lets and Vars
        private lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = setupFetchedResultsController()
        
        // MARK: - Init&Co.
        override func viewDidLoad() {
            super.viewDidLoad()
            navigationItem.title = "Buddy List"
            
        }
        
        // Segue Handling
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == BuddyListTableViewController.OpenEditBuddyFormViewControllerSegueKey {
                if let buddy = sender as? Buddy {
                    guard let navController = segue.destination as? UINavigationController
                        else { fatalError("Must be an UINavigationController.") }
                    guard let editBuddyVC = navController.children[0] as? EditBuddyFormViewController
                        else { fatalError("Must be an EditBuddyFormViewController.") }
                    editBuddyVC.buddy = buddy
                }
            }
            
        }
        
        // MARK: - Private Methods
        private func setupFetchedResultsController()
            -> NSFetchedResultsController<NSFetchRequestResult> {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Buddy")
                let sortDesc = NSSortDescriptor(key: "name", ascending: true)
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
    extension BuddyListTableViewController {
        
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
                let cell = tableView.dequeueReusableCell(withIdentifier: BuddyListTableViewController.BuddyListTableViewCellIdentifierKey,
                                                         for: indexPath)
                
                // Set up the cell
                guard let buddy = self.fetchedResultsController.object(at: indexPath) as? Buddy
                    else { fatalError("Attempt to configure cell without a managed object") }
                
                //Populate the cell from the object
                cell.imageView?.image = UIImage(systemName: "person")
                cell.textLabel?.text = buddy.name
                
                return cell
        }
                
        // Delete Buddy via Swipe to left
        override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
                let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
                    
                    guard let buddy = self.fetchedResultsController.object(at: indexPath) as? Buddy
                        else { fatalError("Attempt to configure cell without a managed object") }

                    let editContext = CoreDataManager.editContextForUI()
                    let buddyInEditContext = editContext.object(with: buddy.objectID)
                    editContext.delete(buddyInEditContext)
                    editContext.saveContext()
                }
                
                let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
                configuration.performsFirstActionWithFullSwipe = false
                return configuration
        }
        
        // Edit Buddy via Swipe to right
        override func tableView(_ tableView: UITableView,
                                leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
                let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, complete in
                    
                    guard let buddy = self.fetchedResultsController.object(at: indexPath) as? Buddy
                        else { fatalError("Attempt to configure cell without a managed object") }
                    
                    self.performSegue(withIdentifier: BuddyListTableViewController.OpenEditBuddyFormViewControllerSegueKey,
                                      sender: buddy)
                    
                }
                
                let configuration = UISwipeActionsConfiguration(actions: [editAction])
                configuration.performsFirstActionWithFullSwipe = false
                return configuration
                
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate
    extension BuddyListTableViewController: NSFetchedResultsControllerDelegate {
        
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
