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
    static let GliderRegistrationKey = "Glider Registration"
    static let GliderRatioKey = "Glider Ratio"
    static let GliderFlarmIDKey = "FLARM ID"
    // MARK: - Lets and Vars
    var gliderToEdit: Glider?

    private let viewOnlyContext: NSManagedObjectContext = {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
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

    // MARK: - Public Class Methods

    // MARK: - Public Methods

    // MARK: - Private Methods
    // MARK: Eureka Form Sections
    private func gliderSelectionSection()
        -> Section {
            let section = Section("Glider Details")

                <<< TextRow { row in
                    row.title = EditGliderFormViewController.GliderRegistrationKey
                    row.tag = EditGliderFormViewController.GliderRegistrationKey

                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "textformat")
                }.onChange({ row in
                    self.gliderToEdit?.registration = row.value
                })

                <<< TextRow { row in
                    row.title = EditGliderFormViewController.GliderRatioKey
                    row.tag = EditGliderFormViewController.GliderRatioKey

                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "arrow.down.left")
                }

                <<< TextRow { row in
                    row.title = EditGliderFormViewController.GliderFlarmIDKey
                    row.tag = EditGliderFormViewController.GliderFlarmIDKey

                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(systemName: "dot.radiowaves.left.and.right")

            }

            section.tag = "Glider Details"
            return section
    }

    // MARK: - Action Methods
    // Cancel Button tapped
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)

    }

    // Save button tapped
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {

        // Save Glider Values to Context
        if let registrationRow = self.form.rowBy(tag: EditGliderFormViewController.GliderRegistrationKey) as? TextRow {
            print(registrationRow.value!)
        }

        if let ratioRow = self.form.rowBy(tag: EditGliderFormViewController.GliderRatioKey) as? TextRow {
            print(ratioRow.value!)
        }

        if let flarmIDRow = self.form.rowBy(tag: EditGliderFormViewController.GliderFlarmIDKey) as? TextRow {
            print(flarmIDRow.value!)
        }

        self.dismiss(animated: true, completion: nil)

    }

    // MARK: - Extentsions

}
