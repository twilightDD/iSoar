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

    @NSManaged public var uuid: UUID?
    @NSManaged public var taskName: String?
    @NSManaged public var taskEntries: NSSet?

}

// MARK: Generated accessors for taskEntries
extension Task {

    @objc(addTaskEntriesObject:)
    @NSManaged public func addToTaskEntries(_ value: Airport)

    @objc(removeTaskEntriesObject:)
    @NSManaged public func removeFromTaskEntries(_ value: Airport)

    @objc(addTaskEntries:)
    @NSManaged public func addToTaskEntries(_ values: NSSet)

    @objc(removeTaskEntries:)
    @NSManaged public func removeFromTaskEntries(_ values: NSSet)

}

extension Task : Identifiable {

}
