//
//  NSManagedObjectContext+Fetch.swift
//  Glider Tool
//
//  Created by sonic on 03.08.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    func fetchObjects <T: NSManagedObject>(forEntityClass entityClass: T.Type,
                                           sortByKeypath keyPath: String? = nil,
                                           sortAscending ascending: Bool = true,
                                           predicateString: String? = nil,
                                           predicateArguments: [Any]? = nil)
        -> [T] {
            
            var sortDescriptors: [NSSortDescriptor]?
            if let keyPath = keyPath {
                sortDescriptors = [NSSortDescriptor.init(key: keyPath, ascending: ascending)]
            }
            
            var predicate: NSPredicate?
            if let predicateString = predicateString,
                let predicateArguments = predicateArguments {
                predicate = NSPredicate.init(format: predicateString, argumentArray: predicateArguments)
            }
            
            let fetchedResult = fetchObjects(forEntityClass: entityClass,
                                             sortDescriptors: sortDescriptors,
                                             predicate: predicate)
            return fetchedResult
    }
    
    func fetchObjects <T: NSManagedObject>(forEntityClass entityClass: T.Type,
                                           sortDescriptors: [NSSortDescriptor]? = nil,
                                           predicate: NSPredicate? = nil)
        -> [T] {
        
            let request: NSFetchRequest<T>
            request = entityClass.fetchRequest() as! NSFetchRequest<T>
            request.returnsObjectsAsFaults = false
            
            request.sortDescriptors = sortDescriptors
            request.predicate = predicate
            
            do {
                let fetchedResult = try self.fetch(request)
                return fetchedResult
            } catch let fetchError {
                print("\(fetchError.localizedDescription)")
                fatalError()
            }
    }
    
    func countOfObjects <T: NSManagedObject>(forEntityClass entityClass: T.Type,
                                             predicate: NSPredicate? = nil)
        -> Int {
            
            let request: NSFetchRequest<T>
            request = entityClass.fetchRequest() as! NSFetchRequest<T>
            request.predicate = predicate
            
            do {
                let count = try self.count(for: request)
                return count
            } catch let fetchError {
                print("\(fetchError.localizedDescription)")
                fatalError()
            }
    }
        
}
