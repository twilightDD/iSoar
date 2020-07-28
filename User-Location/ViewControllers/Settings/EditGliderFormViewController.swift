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
            } else {
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
    
    // MARK: IBOutlets
    @IBOutlet weak var cancelBarBauttonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
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
            
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = Locale.current
            numberFormatter.numberStyle = .decimal
            numberFormatter.minimumFractionDigits = 1
            numberFormatter.maximumFractionDigits = 1
            
            section
                <<< TextRow(EditGliderFormViewController.GliderRegistrationKey) { row in
                    row.title = "Glider Registration"
                    row.value = self.glider.registration
                    row.placeholder = "D-1234"
                    row.add(rule: RuleRequired())
                    row.add(rule: RuleMinLength(minLength: 6))
                    row.add(rule: RuleMaxLength(maxLength: 7))
                    row.validationOptions = .validatesOnChange
                    
                }.cellUpdate { cell, row in
                    
                    if row.isValid == false {
                        cell.titleLabel?.textColor = .red
                    }
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "textformat")
                }.onChange({ [unowned self] row in
                    self.glider.registration = row.value
                })
                
                <<< DecimalRow(EditGliderFormViewController.GliderRatioKey) { row in
                    row.title = "Glider Ratio"
                    if self.glider.isInserted != true {
                        row.value = self.glider.ratio
                    }
                    row.placeholder = "30"
                    row.add(rule: RuleRequired())
                    row.validationOptions = .validatesOnChange
                    row.formatter = numberFormatter
                    
                }
                .cellUpdate { cell, row in
                    self.validateForm()
                    if row.isValid == false {
                        cell.titleLabel?.textColor = .red
                    }
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "arrow.down.left")
                }.onChange({ (row) in
                    self.glider.ratio = Double(row.value ?? 30)
                })
                
                <<< TextRow(EditGliderFormViewController.GliderFlarmIDKey) { row in
                    row.title = "FlarmID"
                    row.value = self.glider.flarmID
                    row.placeholder = "FLRD12345"
                    row.add(rule: RuleRequired())
                    row.add(rule: RuleMinLength(minLength: 9))
                    row.add(rule: RuleMaxLength(maxLength: 9))
                    row.validationOptions = .validatesOnChange
                    
                }.cellUpdate { cell, row in
                    self.validateForm()
                    if row.isValid == false {
                        cell.titleLabel?.textColor = .red
                    }
                    
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
        let existingGliders = Glider.fetchGliders(registration: glider.registration!,
                                                  flarmID: glider.flarmID!,
                                                  context: editContext)
        if existingGliders.count == 1 {
            editContext.saveContext()
            self.dismiss(animated: true, completion: nil)
        } else if existingGliders.count == 0 {
            fatalError("ich muss self.glider haben.")
        } else {
            let alertViewController = UIAlertController.init(title: "Warning",
                                                             message: "Glider Registration or FlarmID already exists.",
                                                             preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: "OK", style: .cancel) { (action) in
            }
            alertViewController.addAction(cancelAction)
            present(alertViewController, animated: true) {
                
            }
        }
        
    }
    
    private func validateForm() {
        let validationErrors = form.validate()
        if validationErrors.count == 0 {
            saveBarButtonItem.isEnabled = true
        } else {
            saveBarButtonItem.isEnabled = false
        }
    }
    
}
