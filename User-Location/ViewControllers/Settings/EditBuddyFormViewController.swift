//
//  EditBuddyFormViewController.swift
//  Glider Tool
//
//  Created by sonic on 02.08.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Eureka
import CoreData

class EditBuddyFormViewController: FormViewController {

    // MARK: - Keys
    static let BuddyNameKey = "Buddy Name"
    static let BuddyFlarmIDKey = "FLARM ID"
    
    // MARK: - Lets and Vars
    private var _buddy: Buddy?
    var buddy: Buddy {
        get {
            if let storedBuddy = _buddy {
                return storedBuddy
            } else {
                let newBuddy = Buddy.init(context: editContext)
                newBuddy.uuid = UUID()
                _buddy = newBuddy
                return newBuddy
            }
        }
        set {
            guard let buddyInEditContext = editContext.object(with: newValue.objectID) as? Buddy
                else { fatalError() }
            _buddy = buddyInEditContext
        }
    }
    
    private let editContext = CoreDataManager.editContextForUI()
    private let viewOnlyContext = CoreDataManager.viewOnlyContext
    
    // MARK: IBOutlets
    @IBOutlet weak var cancelBarBauttonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarBauttonItem: UIBarButtonItem!

    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Buddy Details"
        
        form.append(buddyListSection())
    }
    
    // MARK: - Private Methods
    // MARK: Eureka Form Sections
    private func buddyListSection()
        -> Section {
            let section = Section("Buddy Details")
            section.tag = "Buddy Details"
            
            section
                <<< TextRow(EditBuddyFormViewController.BuddyNameKey) { row in
                    row.title = "Buddy Name"
                    row.value = self.buddy.name
                    row.placeholder = "Otto / LS8"
                    row.add(rule: RuleRequired())
                    row.add(rule: RuleMinLength(minLength: 2))
                    row.validationOptions = .validatesOnChange
                    
                }.cellUpdate { cell, row in
                    
                    if row.isValid == false {
                        cell.titleLabel?.textColor = .red
                    }
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "textformat")
                }.onChange({ [unowned self] row in
                    let newName = row.value ?? ""
                    self.buddy.name = newName
                })
                
                <<< TextRow(EditBuddyFormViewController.BuddyFlarmIDKey) { row in
                    row.title = "FlarmID"
                    row.value = self.buddy.flarmID
                    row.placeholder = "FLRD12345"
                    row.add(rule: RuleRequired())
                    row.add(rule: RuleMinLength(minLength: 9))
                    row.add(rule: RuleMaxLength(maxLength: 9))
                    row.validationOptions = .validatesOnChange
                    
                }.cellUpdate { cell, row in
                    //self.validateForm()
                    if row.isValid == false {
                        cell.titleLabel?.textColor = .red
                    }
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "dot.radiowaves.left.and.right")
                }.onChange({ (row) in
                    let newFlarmID = row.value ?? ""
                    self.buddy.flarmID = newFlarmID
                })
            
            return section
    }
    
    private func validateForm() {
        let validationErrors = form.validate()
        if validationErrors.count == 0 {
            saveBarBauttonItem.isEnabled = true
        } else {
            saveBarBauttonItem.isEnabled = false
        }
    }
    
    // MARK: - Action Methods
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {

        let existingBuddies = editContext.fetchObjects(forEntityClass: Buddy.self,
                                            predicateString: "%K == %@ OR %K == %@",
                                            predicateArguments: [Buddy.Attributes.name, buddy.name,
                                                                 Buddy.Attributes.flarmID, buddy.flarmID])
        if existingBuddies.count == 1 {
            editContext.saveContext()
            
            OGNSocketConnectionManager.didUpdateBuddies()
            
            // Baue String aus allen FlarmIDs, irgendiwe mit join (FRLD12345/ICA12345)
            
            // Setze den String in den UserDefaults
            // let flarmBuddyFlarmID = coredata.alleFlarmIDs
            //UserDefaultsManager.set(flarmBuddyFlarmID: joinedFlarmIDs ?? "FLRxxxxxx")
            
            // Wenn Show only Buddies an, dann reconnect
            // if UserDefaultsManager.showAllNearbyGlidersState() == true,
            // UserDefaultsManager.showOnlyBuddySwitchState() == true {
            //
            // OGNSocketConnectionManager.reconnect()
            // }
            
            self.dismiss(animated: true, completion: nil)
        } else if existingBuddies.count == 0 {
            fatalError("ich muss self.buddy haben.")
        } else {
            let alertViewController = UIAlertController.init(title: "Warning",
                                                             message: "Buddy Name or FlarmID already exists.",
                                                             preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: "OK", style: .cancel) { (action) in
            }
            alertViewController.addAction(cancelAction)
            present(alertViewController, animated: true) {
                
            }
        }
        
    }

}
