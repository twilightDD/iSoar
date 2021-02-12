//
//  Waypoint+CoreDataClass.swift
//  Glider Tool
//
//  Created by sonic on 04.02.21.
//  Copyright © 2021 Denis Leupold. All rights reserved.
//
//

import CoreData

@objc(Waypoint)
public class Waypoint: NSManagedObject {

}

extension Waypoint {
    struct Attributes {
        static let uuid = "uuid"
        
    }
    
    struct Relationships {
        static let tasks = "tasks"
        static let airport = "airport"
        
    }
}
