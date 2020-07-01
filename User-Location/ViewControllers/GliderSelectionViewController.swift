//
//  GliderSelectionViewController.swift
//  Glider Tool
//
//  Created by sonic on 25.06.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import UIKit
import CoreData

class GliderSelectionTableViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Lets and Vars

    weak var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var context: NSManagedObjectContext!
    
    var gliderArray = [Gliders]()

    var gliderID: UITextField!
    var gliderRatio: UITextField!
    var flarmID: UITextField!

    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Glider Selection"

    }

    // MARK: - Private Methods
    // Methods to Open, Store and Fetch data
    private func openDatabse() {
        context = appDelegate!.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Gliders", in: context)
        let newGlider = NSManagedObject(entity: entity!, insertInto: context)
        saveData(userDBObj: newGlider)
    }

    private func saveData(userDBObj: NSManagedObject) {
        userDBObj.setValue(gliderID.text, forKey: "gliderID")

        let gliderRatioString = gliderRatio.text
        let gliderRatioDouble = (gliderRatioString! as NSString).doubleValue
        userDBObj.setValue(gliderRatioDouble, forKey: "gliderRatio")

        userDBObj.setValue(flarmID.text, forKey: "gliderFlarmID")

        print("Storing Data..")
        do {
            try context.save()
        } catch {
            print("Storing data Failed")
        }

        fetchData()
    }

    private func fetchData() {
        print("Fetching Data..")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Gliders")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                //context.delete(data)

                let gliderID = data.value(forKey: "gliderID") as! String
                let gliderRatio = data.value(forKey: "gliderRatio") as! Double
                let gliderFlarmID = data.value(forKey: "gliderFlarmID") as! String
                
                let glider = Gliders()
                glider.gliderID = gliderID
                glider.gliderRatio = gliderRatio
                glider.gliderFlarmID = gliderFlarmID
                gliderArray.append(glider)

                print("Glider ID is: \(gliderID) FLARM ID is: \(gliderFlarmID) Ratio is: \(gliderRatio)")
            }

            //try context.save()

        } catch {
            print("Fetching data Failed")
        }
        
    }
    
    
    // TablewView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gliderArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let glider = gliderArray[indexPath.row]
        
        cell.textLabel?.text = glider.gliderID
        
        return cell
    }

    // MARK: - Action Methods
    // Add new Glider Button
    @IBAction func addGliderAction(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: "Add new Glider to Hangar",
                                      message: "Please insert Glider Details",
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action)
            -> Void in

            self.openDatabse()

        }

        // Add Textfields
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Glider Registration e.g. D-1234"
            textField.keyboardType = .default
            self.gliderID = textField
        })

        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Lift to Drag Ratio e.g. 35"
            self.gliderRatio = textField
        })

        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "FLARM ID e.g. FLR123456"
            self.flarmID = textField
        })

        // Add Action Buttons
        alert.addAction(cancelAction)
        alert.addAction(saveAction)

        self.present(alert, animated: true, completion: nil)
    }

}
