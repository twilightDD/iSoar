//
//  CoreDataController.swift
//  Glider Tool
//
//  Created by sonic on 17.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import CoreData

class CoreDataController {
    // MARK: - Lets and Vars
    private static let sharedManager = CoreDataController()
    
    // MARK: - Public Class Methods
    // Check if Entity is empty
    class func entityIsEmpty(entity: String) {
        do {
            let context = CoreDataManager.viewOnlyContext
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
            let count = try context.count(for: request)
            
            // TODO: 17.11.2020 Prefer checking `isEmpty` over comparing `count` to zero. (empty_count)
            if count < 1 {
                print("OBJEKTE IN ENTITY \(entity): \(count) - WE HAVE TO IMPORT DATA")
            } else {
                print("OBJEKTE IN ENTITY \(entity): \(count)")
            }

        } catch {
            print("ERROR")
        }
        
    }
    
}
