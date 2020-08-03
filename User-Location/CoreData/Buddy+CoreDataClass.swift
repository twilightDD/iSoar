//
//  Buddy+CoreDataClass.swift
//  
//
//  Created by sonic on 02.08.20.
//
//

import CoreData

@objc(Buddy)
public class Buddy: NSManagedObject {
    
    class func allFlarmIDs(inContext context: NSManagedObjectContext? = nil)
        -> [String] {
            let contextToUse = context ?? CoreDataManager.viewOnlyContext
            
            let allBuddies = contextToUse.fetchObjects(forEntityClass: Buddy.self,
                                                       sortByKeypath: Buddy.Attributes.flarmID)
            
            let allFlarmIDs = allBuddies.compactMap { $0.flarmID }
            return allFlarmIDs
    }
    
}

extension Buddy {
    struct Attributes {
        static let flarmID = "flarmID"
        static let name = "name"
        static let uuid = "uuid"
    }
}
