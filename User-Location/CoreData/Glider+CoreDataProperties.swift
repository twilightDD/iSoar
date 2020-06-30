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

    @NSManaged public var gliderFlarmID: String?
    @NSManaged public var gliderID: String?
    @NSManaged public var gliderRatio: Double

}
