//
//  Task+CoreDataProperties.swift
//  Glider Tool
//
//  Created by sonic on 07.02.21.
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

    @NSManaged public var waypoints: [Waypoint]?

}

// MARK: Generated accessors for waypoints
extension Task {

    @objc(insertObject:inWaypointsAtIndex:)
    @NSManaged public func insertIntoWaypoints(_ value: Waypoint, at idx: Int)

    @objc(removeObjectFromWaypointsAtIndex:)
    @NSManaged public func removeFromWaypoints(at idx: Int)

    @objc(insertWaypoints:atIndexes:)
    @NSManaged public func insertIntoWaypoints(_ values: [Waypoint], at indexes: NSIndexSet)

    @objc(removeWaypointsAtIndexes:)
    @NSManaged public func removeFromWaypoints(at indexes: NSIndexSet)

    @objc(replaceObjectInWaypointsAtIndex:withObject:)
    @NSManaged public func replaceWaypoints(at idx: Int, with value: Waypoint)

    @objc(replaceWaypointsAtIndexes:withWaypoints:)
    @NSManaged public func replaceWaypoints(at indexes: NSIndexSet, with values: [Waypoint])

    @objc(addWaypointsObject:)
    @NSManaged public func addToWaypoints(_ value: Waypoint)

    @objc(removeWaypointsObject:)
    @NSManaged public func removeFromWaypoints(_ value: Waypoint)

    @objc(addWaypoints:)
    @NSManaged public func addToWaypoints(_ values: NSOrderedSet)

    @objc(removeWaypoints:)
    @NSManaged public func removeFromWaypoints(_ values: NSOrderedSet)

}

extension Task: Identifiable {

}
