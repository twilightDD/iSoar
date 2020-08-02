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
    class func fetchBuddies(name: String,
                            flarmID: String,
                            context: NSManagedObjectContext)
        -> [Buddy] {
            let request = NSFetchRequest<Buddy>(entityName: Buddy.entityName())
            
            let registrationPredicate = NSPredicate.init(format: "%K == %@",
                                                         Buddy.Attributes.name, name)
            let flarmIDPredicate = NSPredicate.init(format: "%K == %@",
                                                                    Buddy.Attributes.flarmID, flarmID)
            let orPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: [registrationPredicate, flarmIDPredicate])
            request.predicate = orPredicate
            
            do {
                let fetchedBuddies = try context.fetch(request)
                return fetchedBuddies
                // TODO: baue eine neue methode, die nur count zurück liefert
                //context.count(for: request)
            } catch let fetchError {
                print("\(fetchError)")
                fatalError()
            }
    }
}

extension Buddy {
    struct Attributes {
        static let flarmID = "flarmID"
        static let name = "name"
        static let uuid = "uuid"
    }
}
