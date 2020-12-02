//
//  GliderModelSelectionViewController.swift
//  Glider Tool
//
//  Created by sonic on 02.12.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import UIKit
import CoreData

class GliderModelSelectionViewController: UITableViewController {
    
    // MARK: - Keys
    private static let GliderModelSelectionTableViewCellIdentifierKey = "GliderModelSelectionTableViewCellIdentifier"

    // MARK: - Lets and Vars
    private lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = setupFetchedResultsController()
    
    private var previouslySelectedGliderModel: GliderModel?

    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Model Selection"
        
    }

// MARK: - Public Class Methods

// MARK: - Public Methods

    // MARK: - Private Methods
    private func setupFetchedResultsController()
        -> NSFetchedResultsController<NSFetchRequestResult> {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GliderModel")
            let sortDesc = NSSortDescriptor(key: "modelName", ascending: true)
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
extension GliderModelSelectionViewController {
    
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
            let cell = tableView.dequeueReusableCell(withIdentifier: GliderModelSelectionViewController.GliderModelSelectionTableViewCellIdentifierKey,
                                                     for: indexPath)
            
            // Set up the cell
            guard let gliderModel = self.fetchedResultsController.object(at: indexPath) as? GliderModel
                else { fatalError("Attempt to configure cell without a managed object") }
            
            //Populate the cell from the object
            cell.imageView?.image = UIImage(systemName: "airplane")
            cell.textLabel?.text = gliderModel.modelName
            
            // Set Checkmark for selected Glider
//            if gliderModel.registration == UserDefaultsManager.gliderID() {
//                cell.accessoryType = .checkmark
//            } else {
//                cell.accessoryType = .none
//            }
            
            return cell
    }
    
    // User didSelect Row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}

    // MARK: - NSFetchedResultsControllerDelegate
    extension GliderModelSelectionViewController: NSFetchedResultsControllerDelegate {
        
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
