//
//  EditGliderFormViewController.swift
//  Glider Tool
//
//  Created by sonic on 03.07.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Eureka
import CoreData

class EditGliderFormViewController: FormViewController {
    
    // MARK: - Keys
    static let GliderRegistrationKey = "GliderRegistration"
    static let GliderRatioKey = "Glider Ratio"
    static let GliderFlarmIDKey = "FLARM ID"
    
    // MARK: - Lets and Vars
    var glider: Glider?
    private let viewOnlyContext: NSManagedObjectContext = {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = CoreDataManager.sharedManager.persistentContainer.viewContext
            return context
        }
        fatalError()
    }()
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Glider Details"
        
        form.append(gliderSelectionSection())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if glider == nil {
            glider = Glider.init(context: viewOnlyContext)
        }
    }
    
    // MARK: - Private Methods
    // MARK: Eureka Form Sections
    private func gliderSelectionSection()
        -> Section {
            let section = Section("Glider Details")
            section.tag = "Glider Details"
            
            section
                <<< TextRow(EditGliderFormViewController.GliderRegistrationKey) { row in
                    row.title = "Glider Registration"
                    row.value = self.glider?.registration
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "textformat")
                }.onChange({ [unowned self] row in
                    self.glider?.registration = row.value
                })
                
                <<< DecimalRow(EditGliderFormViewController.GliderRatioKey) { row in
                    row.title = "Glider Ratio"
                    row.value = self.glider?.ratio
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "arrow.down.left")
                }.onChange({ (row) in
                    self.glider?.ratio = row.value ?? 0
                })
                
                <<< TextRow(EditGliderFormViewController.GliderFlarmIDKey) { row in
                    row.title = "FlarmID"
                    row.value = self.glider?.flarmID
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "dot.radiowaves.left.and.right")
                }.onChange({ (row) in
                    self.glider?.flarmID = row.value
                })
            
            return section
    }
    
    // MARK: - Action Methods
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if glider?.isInserted == true {
            viewOnlyContext.delete(glider!)
        } else {
            viewOnlyContext.refresh(glider!, mergeChanges: false)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        do {
            try viewOnlyContext.save()
        } catch let saveError {
            print("\(saveError)")
            fatalError()
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
