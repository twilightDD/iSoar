//
//  Glider+CoreDataClass.swift
//  
//
//  Created by sonic on 29.06.20.
//
//

import CoreData

@objc(Glider)
public class Glider: NSManagedObject {
    class func fetchGliders(registration: String,
                            flarmID: String,
                            context: NSManagedObjectContext)
        -> [Glider] {
            let request = NSFetchRequest<Glider>(entityName: Glider.entityName())
            
            let registrationPredicate = NSPredicate.init(format: "%K == %@",
                                                         Glider.Attributes.registration, registration)
            let flarmIDPredicate = NSPredicate.init(format: "%K == %@",
                                                                    Glider.Attributes.flarmID, flarmID)
            let orPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: [registrationPredicate, flarmIDPredicate])
            request.predicate = orPredicate
            
            do {
                let fetchedGliders = try context.fetch(request)
                return fetchedGliders
                // TODO: baue eine neue methode, die nur count zurück liefert
                //context.count(for: request)
            } catch let fetchError {
                print("\(fetchError)")
                fatalError()
            }
    }
}

extension Glider {
    struct Attributes {
        static let flarmID = "flarmID"
        static let ratio = "ratio"
        static let registration = "registration"
        static let uuid = "uuid"
    }
}
