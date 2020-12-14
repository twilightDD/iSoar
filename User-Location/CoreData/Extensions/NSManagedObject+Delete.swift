//
//  NSManagedObject+Delete.swift
//  Glider Tool
//
//  Created by sonic on 14.12.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

import CoreData

// MARK: - Extension - Delete
extension NSManagedObject {

    //MARK: - Public Class Methods

    @discardableResult
    class func deleteAll(predicate: NSPredicate? = nil,
                         inContext context: NSManagedObjectContext? = CoreDataManager.editContextInBackground())
    -> Int {
        let objectsToDelete = context?.fetchObjects(forEntityClass: self,
                                                    predicate: predicate)
        let count = objectsToDelete?.count
        objectsToDelete?.forEach { $0.forget() }

        context?.saveContext()
        return count ?? 0
    }

    
    //MARK: - Public Instance Methods
    @discardableResult
    func forget()
        -> Bool {
            if isDeleted == true {
                return true
            }
            
            guard let context = managedObjectContext
                else { fatalError("Could not delete managedObject; context is nil.") }
            
            context.delete(self)
            
            return true
    }
    
}
