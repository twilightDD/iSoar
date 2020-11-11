//
//  Glider+CoreDataProperties.swift
//  Glider Tool
//
//  Created by sonic on 11.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//
//

import Foundation
import CoreData


extension Glider {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Glider> {
        return NSFetchRequest<Glider>(entityName: "Glider")
    }

    @NSManaged public var flarmID: String?
    @NSManaged public var ratio: Double
    @NSManaged public var registration: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var gliderModel: GliderModel?

}

extension Glider : Identifiable {

}
