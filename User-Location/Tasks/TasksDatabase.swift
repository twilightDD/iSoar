//
//  TasksDatabase.swift
//  Glider Tool
//
//  Created by sonic on 06.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import CoreLocation

//MARK: - AirportDatabase
class TasksDatabase {
    static let shared = TasksDatabase()

    class func gpxFileNames()
        -> [String] {
            let gpxFileNames = ISoarFileManager.gpxFileNames()

            return gpxFileNames
    }

}
