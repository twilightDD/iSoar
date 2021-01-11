//
//  Task+CoreDataClass.swift
//  Glider Tool
//
//  Created by sonic on 10.01.21.
//  Copyright © 2021 Denis Leupold. All rights reserved.
//
//

import CoreData

@objc(Task)
public class Task: NSManagedObject {

}

extension Task {
    struct Attributes {
        static let taskName = "taskName"
        static let uuid = "uuid"
    }
}
