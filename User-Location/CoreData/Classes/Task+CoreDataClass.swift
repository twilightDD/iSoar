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
    class func fetchTasks(taskName: String,
                           context: NSManagedObjectContext)
    -> [Task] {
        let taskNamePredicate = NSPredicate.init(format: "%K == %@",
                                                 Task.Attributes.taskName, taskName)
        
        let tasks = context.fetchObjects(forEntityClass: Task.self,
                                         predicate: taskNamePredicate)
        return tasks
    }
    
}

extension Task {
    struct Attributes {
        static let taskName = "taskName"
        static let uuid = "uuid"
    }
}
