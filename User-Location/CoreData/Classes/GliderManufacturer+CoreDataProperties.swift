//
//  GliderManufacturer+CoreDataProperties.swift
//  Glider Tool
//
//  Created by sonic on 10.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//
//

import Foundation
import CoreData


extension GliderManufacturer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GliderManufacturer> {
        return NSFetchRequest<GliderManufacturer>(entityName: GliderManufacturer.entityName())
    }

    @NSManaged public var manufacturerName: String?

}
