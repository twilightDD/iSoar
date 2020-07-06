//
//  GliderSelectionViewController.swift
//  Glider Tool
//
//  Created by sonic on 25.06.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import UIKit
import CoreData

class GliderSelectionTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Keys
    private static let GliderEntityName = "Glider"
    
    // MARK: - Lets and Vars
    weak var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var context: NSManagedObjectContext!
    
    var gliderArray = [Glider]()
    
    var gliderUUID: UUID!
    var gliderIDTextField: UITextField!
    var gliderRatioTextField: UITextField!
    var flarmIDTextField: UITextField!
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Glider Selection"
        
        context = appDelegate!.persistentContainer.viewContext
        fetchData()
        
    }
    
    // MARK: - Private Methods
    // Create new Glider
    private func createNewGlider() {
        let newGlider = Glider.init(context: context)
        newGlider.uuid = UUID()
        newGlider.flarmID = flarmIDTextField.text
        newGlider.registration = gliderIDTextField.text
        newGlider.ratio = (gliderRatioTextField.text! as NSString).doubleValue
        
        do {
            try context.save()
            fetchData()
        } catch {
            fatalError()
        }
        
    }
    
    // Fetch Data from Core Data Stack
    private func fetchData() {
        gliderArray.removeAll()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: GliderSelectionTableViewController.GliderEntityName)
        request.returnsObjectsAsFaults = false
        context.reset()
        do {
            let request: NSFetchRequest<Glider> = Glider.fetchRequest()
            gliderArray = try context.fetch(request)
        } catch {
            print("Fetching data Failed")
        }
        tableView.reloadData()
    }
    
    // MARK: - TablewView Methods
    // Setup TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
            return gliderArray.count
    }
    
    // Setup TableViewCell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let cell = UITableViewCell()
            let glider = gliderArray[indexPath.row]
            
            cell.textLabel?.text = glider.registration
            cell.imageView?.image = UIImage(systemName: "airplane")
            
            // Set Checkmark
            if gliderArray[indexPath.row].registration == UserDefaultsManager.gliderID() {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
    }
    
    // User didSelect Row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedGlider = gliderArray[indexPath.row]
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        UserDefaultsManager.set(gliderID: selectedGlider.registration!)
        UserDefaultsManager.set(gliderRatio: selectedGlider.ratio)
        UserDefaultsManager.set(ownFlarmID: selectedGlider.flarmID!)
        
        tableView.reloadData()
        
        // TODO: 20200703 Hier nochmal prüfen ob ein anderer Glider ausgewählt wurde
        // Reconnect to OGN Server
        if UserDefaultsManager.showAllNearbyGlidersState() == true {
            OGNSocketConnectionManager.reconnect()
            
        }
        
    }
    
    // Delete Glider via Swipe to left
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, complete in
                
                if self.gliderArray.isEmpty == false {
                    let glider = self.gliderArray[indexPath.row]
                    self.context.delete(glider)
                    self.gliderArray.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                }
                
                do {
                    try self.context.save()
                    self.fetchData()
                } catch {
                    fatalError()
                }
            }
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
            
    }
    
    // Edit Glider via Swipe to right
    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
            let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, complete in
                
                print("Swiped right and tapped on Edit")
                
            }
            
            let configuration = UISwipeActionsConfiguration(actions: [editAction])
            //configuration.performsFirstActionWithFullSwipe = true
            return configuration
            
    }
    
//    // MARK: - Action Methods
//    // Add new Glider Button
//    @IBAction func addGliderAction(_ sender: UIBarButtonItem) {
//        let alert = UIAlertController(title: "Add new Glider to Hangar",
//                                      message: "Please insert Glider Details",
//                                      preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        let saveAction = UIAlertAction(title: "Save", style: .default) { (action)
//            -> Void in
//
//            self.createNewGlider()
//
//        }
//
//        // Add Textfields
//        alert.addTextField(configurationHandler: {(textField: UITextField!) in
//            textField.placeholder = "Glider Registration e.g. D-1234"
//            self.gliderIDTextField = textField
//        })
//
//        alert.addTextField(configurationHandler: {(textField: UITextField!) in
//            textField.placeholder = "Lift to Drag Ratio e.g. 35"
//            self.gliderRatioTextField = textField
//        })
//
//        alert.addTextField(configurationHandler: {(textField: UITextField!) in
//            textField.placeholder = "FLARM ID e.g. FLR123456"
//            self.flarmIDTextField = textField
//        })
//
//        // Add Action Buttons
//        alert.addAction(cancelAction)
//        alert.addAction(saveAction)
//
//        self.present(alert, animated: true, completion: nil)
//    }
    
}
