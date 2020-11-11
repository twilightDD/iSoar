//
//  GliderManufacturer+CoreDataProperties.swift
//  Glider Tool
//
//  Created by sonic on 11.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//
//

import CoreData

extension GliderManufacturer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GliderManufacturer> {
        return NSFetchRequest<GliderManufacturer>(entityName: GliderManufacturer.entityName())
    }

    @NSManaged public var manufacturerName: String
    @NSManaged public var uuid: UUID
    
    @NSManaged public var gliderModels: NSSet?

}

// MARK: Generated accessors for gliderModels
extension GliderManufacturer {

    @objc(addGliderModelsObject:)
    @NSManaged public func addToGliderModels(_ value: GliderModel)

    @objc(removeGliderModelsObject:)
    @NSManaged public func removeFromGliderModels(_ value: GliderModel)

    @objc(addGliderModels:)
    @NSManaged public func addToGliderModels(_ values: NSSet)

    @objc(removeGliderModels:)
    @NSManaged public func removeFromGliderModels(_ values: NSSet)

}

extension GliderManufacturer : Identifiable {

}
