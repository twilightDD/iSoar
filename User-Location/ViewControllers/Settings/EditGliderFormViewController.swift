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
    private var _glider: Glider?
    var glider: Glider {
        get {
            if let storedGlider = _glider {
                return storedGlider
            }
            else {
                let newGlider = Glider.init(context: editContext)
                _glider = newGlider
                return newGlider
            }
        }
        set {
            guard let gliderInEditContext = editContext.object(with: newValue.objectID) as? Glider
                else { fatalError() }
            _glider = gliderInEditContext
        }
    }
    private let editContext = CoreDataManager.editContextForUI()
    
    // MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Glider Details"
        
        form.append(gliderSelectionSection())
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
                    row.value = self.glider.registration
                    row.placeholder = "D-1234"
                
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "textformat")
                }.onChange({ [unowned self] row in
                    self.glider.registration = row.value
                })
                
                <<< DecimalRow(EditGliderFormViewController.GliderRatioKey) { row in
                    row.title = "Glider Ratio"
                    row.value = self.glider.ratio
                    row.placeholder = "38"
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "arrow.down.left")
                }.onChange({ (row) in
                    self.glider.ratio = row.value ?? 0
                })
                
                <<< TextRow(EditGliderFormViewController.GliderFlarmIDKey) { row in
                    row.title = "FlarmID"
                    row.value = self.glider.flarmID
                    row.placeholder = "FLRD123456"
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "dot.radiowaves.left.and.right")
                }.onChange({ (row) in
                    self.glider.flarmID = row.value
                })
            
            return section
    }
    
    // MARK: - Action Methods
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {

        editContext.saveContext()

        self.dismiss(animated: true, completion: nil)
    }
    
}
