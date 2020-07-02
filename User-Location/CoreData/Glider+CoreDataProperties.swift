//
//  Glider+CoreDataProperties.swift
//  
//
//  Created by sonic on 29.06.20.
//
//

import Foundation
import CoreData

extension Glider {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Glider> {
        return NSFetchRequest<Glider>(entityName: "Glider")
    }

    @NSManaged public var uuid: UUID?
    @NSManaged public var flarmID: String?
    @NSManaged public var registration: String?
    @NSManaged public var ratio: Double

}
