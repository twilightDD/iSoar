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
            let registrationPredicate = NSPredicate.init(format: "%K == %@",
                                                         Glider.Attributes.registration, registration)
            let flarmIDPredicate = NSPredicate.init(format: "%K == %@",
                                                    Glider.Attributes.flarmID, flarmID)
            let orPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: [registrationPredicate, flarmIDPredicate])

            let gliders = context.fetchObjects(forEntityClass: Glider.self,
                                               predicate: orPredicate)
            return gliders
    }

}

extension Glider {
    struct Attributes {
        static let flarmID = "flarmID"
        static let ratio = "ratio"
        static let registration = "registration"
        static let uuid = "uuid"
    }

    struct Relationships {
        static let glidersModel = "gliderModel"
    }
}
