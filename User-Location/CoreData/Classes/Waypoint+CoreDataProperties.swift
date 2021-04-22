//
//  Waypoint+CoreDataProperties.swift
//  Glider Tool
//
//  Created by sonic on 11.01.21.
//  Copyright © 2021 Denis Leupold. All rights reserved.
//
//

import CoreData

extension Waypoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Waypoint> {
        return NSFetchRequest<Waypoint>(entityName: Waypoint.entityName())
    }

    @NSManaged public var uuid: UUID?
    @NSManaged public var task: Task?

    @NSManaged public var airport: Airport?

}

extension Waypoint: Identifiable {

}
