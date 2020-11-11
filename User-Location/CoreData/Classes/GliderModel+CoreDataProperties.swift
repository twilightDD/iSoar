//
//  GliderModel+CoreDataProperties.swift
//  Glider Tool
//
//  Created by sonic on 10.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//
//

import CoreData

extension GliderModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GliderModel> {
        return NSFetchRequest<GliderModel>(entityName: GliderModel.entityName())
    }

    @NSManaged public var modelName: String?

}
