//
//  CoreDataManager.swift
//  Glider Tool
//
//  Created by sonic on 16.07.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import CoreData

// MARK: - CoreDataManager
class CoreDataManager {
    
    // MARK: - Lets and Vars
    private static let sharedManager = CoreDataManager()

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Glider Tool")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }()

    // MARK: - Init&Co.
    // Prevent clients from creating another instance
    private init() {}

}

// MARK: - Extension - Context Related Methods
extension CoreDataManager {

    static let viewOnlyContext: NSManagedObjectContext = {
        let shared = CoreDataManager.sharedManager
        let viewContext = shared.persistentContainer.viewContext
        
        // merges changes of save to persistentStore, if a newBackgroundContext saves, automatically.
        viewContext.automaticallyMergesChangesFromParent = true
        return viewContext
    }()

    class func editContextForUI()
        -> NSManagedObjectContext {
            let newEditContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
            newEditContext.parent = viewOnlyContext
            newEditContext.name = "UI Edit Context "
            return newEditContext
    }

    class func editContextInBackground()
        -> NSManagedObjectContext {
            let newEditContext = sharedManager.persistentContainer.newBackgroundContext()
            newEditContext.name = "Background Edit Context"
            return newEditContext
    }

}
