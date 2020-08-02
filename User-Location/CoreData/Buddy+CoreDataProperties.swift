//
//  Buddy+CoreDataProperties.swift
//  
//
//  Created by sonic on 02.08.20.
//
//

import CoreData

extension Buddy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Buddy> {
        return NSFetchRequest<Buddy>(entityName: "Buddy")
    }

    @NSManaged public var uuid: UUID?
    @NSManaged public var name: String?
    @NSManaged public var flarmID: String?

}
