//
//  GliderModel+CoreDataProperties.swift
//  Glider Tool
//
//  Created by sonic on 11.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//
//

import CoreData

extension GliderModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GliderModel> {
        return NSFetchRequest<GliderModel>(entityName: GliderModel.entityName())
    }

    @NSManaged public var handicap: Double
    @NSManaged public var manufacturer: String
    @NSManaged public var modelName: String
    @NSManaged public var seats: Double
    @NSManaged public var sink1: Double
    @NSManaged public var sink2: Double
    @NSManaged public var sink3: Double
    @NSManaged public var span: Double
    @NSManaged public var speed1: Double
    @NSManaged public var speed2: Double
    @NSManaged public var speed3: Double
    @NSManaged public var uuid: UUID
    @NSManaged public var wingarea: Double
    @NSManaged public var gliders: NSSet?

}

// MARK: Generated accessors for gliders
extension GliderModel {

    @objc(addGlidersObject:)
    @NSManaged public func addToGliders(_ value: Glider)

    @objc(removeGlidersObject:)
    @NSManaged public func removeFromGliders(_ value: Glider)

    @objc(addGliders:)
    @NSManaged public func addToGliders(_ values: NSSet)

    @objc(removeGliders:)
    @NSManaged public func removeFromGliders(_ values: NSSet)

}

extension GliderModel: Identifiable {

}
