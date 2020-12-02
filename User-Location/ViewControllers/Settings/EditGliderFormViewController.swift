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
        form.append(gliderInformationSection())
    }
    
    func textColor()
        -> UIColor {
            var textColor: UIColor = .black
            
            if self.traitCollection.userInterfaceStyle == .light {
                textColor = .black
            } else {
                textColor = .white
            }
            return textColor
    }
    
    // MARK: - Private Methods
    // MARK: Eureka Form Sections
    private func gliderSelectionSection()
        -> Section {
            let section = Section("Glider Details")
            section.tag = "Glider Details"
            
            let numberFormatter = DecimalFormatter()
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
                
                <<< PushRow<GliderModel>("Glider Model") { row in
                    row.title = "Glider Model"
                    
                    let allGliderModels = editContext.fetchObjects(forEntityClass: GliderModel.self,
                                                                   sortByKeypath: GliderModel.Attributes.modelName)
                    row.options = allGliderModels
                    row.value = self.glider.gliderModel
                    row.displayValueFor = { gliderModel in
                        if gliderModel != nil {
                            return gliderModel?.modelName
                        } else {
                            return "keins"
                        }
                    }
                    row.add(rule: RuleRequired())

                    
                }.cellUpdate { cell, row in
                    if row.isValid == false {
                        cell.textLabel?.textColor = .red
                    }
                    
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "airplane")
                    
                }.onPresent { from, row in
                    row.dismissOnSelection = true
                    row.dismissOnChange = true
                    row.enableDeselection = false
                    row.navigationItem.title = "Glider Model"
                
                }.onChange { row in
                    let selectedGliderModel = row.value
                    self.glider.gliderModel = selectedGliderModel
                }
            
                
                <<< DecimalRow(EditGliderFormViewController.GliderRatioKey) { row in
                    row.title = "Glider Ratio"
                    if self.glider.isInserted != true {
                        row.value = self.glider.ratio
                    }
                    row.placeholder = "30"
                    row.add(rule: RuleRequired())
                    row.validationOptions = .validatesOnChange
                    row.formatter = numberFormatter
                    row.useFormatterDuringInput = true
                    
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
    
    private func gliderInformationSection()
    -> Section {

        let section = Section("Glider Information")
        section.tag = "Glider Information"
        
        let numberFormatter = DecimalFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        
        section
            <<< TextRow("Manufacturer") { row in
                row.title = "Manufacturer"
                row.value = glider.gliderModel?.manufacturer
                row.disabled = true
                
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(systemName: "house")
                
            }.cellUpdate { cell, row in
                cell.titleLabel?.textColor = row.isDisabled ? self.textColor() : self.textColor()
                cell.textField.textColor = row.isDisabled ? self.textColor() : self.textColor()
                
            }
        
        return section
    }
    
    private func validateForm() {
        let validationErrors = form.validate()
        if validationErrors.isEmpty == true {
            saveBarButtonItem.isEnabled = true
        } else {
            saveBarButtonItem.isEnabled = false
        }
    }
    
    // MARK: - Action Methods
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let registration = glider.registration,
            let flarmID = glider.flarmID
            else { fatalError("Save Button tapped while Registration or GliderID is nil") }
        
        let existingGliders = Glider.fetchGliders(registration: registration,
                                                  flarmID: flarmID,
                                                  context: editContext)
        if existingGliders.count == 1 {
            editContext.saveContext()
            self.dismiss(animated: true, completion: nil)
        } else if existingGliders.isEmpty == true {
            fatalError("ich muss self.glider haben.")
        } else {
            let alertViewController = UIAlertController.init(title: "Warning",
                                                             message: "Glider Registration or FlarmID already exists.",
                                                             preferredStyle: .alert)
            
            let cancelAction = UIAlertAction.init(title: "OK",
                                                  style: .cancel) { (action) in
            }
            
            alertViewController.addAction(cancelAction)
            present(alertViewController, animated: true) {
                
            }
        }
        
    }
    
}
