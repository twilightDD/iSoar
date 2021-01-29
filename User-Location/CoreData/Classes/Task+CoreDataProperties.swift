//
//  Task+CoreDataProperties.swift
//  Glider Tool
//
//  Created by sonic on 11.01.21.
//  Copyright © 2021 Denis Leupold. All rights reserved.
//
//

import CoreData

extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: Task.entityName())
    }

    @NSManaged public var taskName: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var airports: [Airport]?

}

extension Task: Identifiable {

}
