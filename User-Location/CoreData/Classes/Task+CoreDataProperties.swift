//
//  Task+CoreDataProperties.swift
//  Glider Tool
//
//  Created by sonic on 10.01.21.
//  Copyright © 2021 Denis Leupold. All rights reserved.
//
//

import CoreData

extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var uuid: UUID?
    @NSManaged public var entries: NSSet?

}

// MARK: Generated accessors for entries
extension Task {

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: Airport)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: Airport)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)

}

extension Task : Identifiable {

}
