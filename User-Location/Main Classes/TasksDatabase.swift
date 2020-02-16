//
//  TasksDatabase.swift
//  Glider Tool
//
//  Created by sonic on 06.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation

var waypoints = [[String: String]]()

// MARK: - TasksDatabase
class TasksDatabase {
    static let shared = TasksDatabase()
    
    class func gpxFileNames()
        -> [String] {
            let gpxFileNames = ISoarFileManager.gpxFileNames()
            
            return gpxFileNames
    }
    
}

// MARK: - Extentsion - Structs and Enums

//extension TasksDatabase {

// TODO:
// extension TasksDatabase: XMLParserDelegate {

struct Waypoint: Equatable {
    // MARK: Lets and Vars
    var latitude: String
    var longitude: String
    
}
