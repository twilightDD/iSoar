//
//  TasksDatabase.swift
//  Glider Tool
//
//  Created by sonic on 06.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - TasksDatabase
class TasksDatabase: NSObject {
    
    // MARK: - Lets and Vars
    static let shared = TasksDatabase()
    
    // TODO: only init! remove content! only for testing Task Lines
    var currentTaskWaypointCoordinates = [CLLocationCoordinate2D]()
    
    class func gpxFileNames()
        -> [String] {
            let gpxFileNames = ISoarFileManager.gpxFileNames()
            
            return gpxFileNames
    }
    
    class func openGPXFile(_ fileName: String) {
        shared.openGPXFile(fileName)
    }
    
    private func openGPXFile(_ fileName: String) {
        guard let filedata = ISoarFileManager.readContentOfSelectedGPXfile(fileName)
            else {return}
        
        let xmlParser = XMLParser.init(data: filedata)
        xmlParser.delegate = self
        xmlParser.parse()
        
    }
    
}

// MARK: - Extentsion - Structs and Enums

struct Waypoint: Equatable {
    // MARK: Lets and Vars
    var latitude: String
    var longitude: String
    
}

extension TasksDatabase: XMLParserDelegate {
    
    // MARK: - Methods
    // Parse Content for Latitude and Longitude
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        
        //Check for the lines that have a <trkpt> or <wpt> tag
        if elementName == "trkpt" || elementName == "wpt" {
            //Create a World map coordinate from the file
            if let waypointLatitude = attributeDict["lat"],
                let waypointLongitude = attributeDict["lon"],
                let latitude = CLLocationDegrees.init(waypointLatitude),
                let longitude = CLLocationDegrees.init(waypointLongitude) {
                
                let waypointCoordinate = CLLocationCoordinate2D(latitude: latitude,
                                                                 longitude: longitude)
                
                TasksDatabase.shared.currentTaskWaypointCoordinates.append(waypointCoordinate)

            }
            
            print(TasksDatabase.shared.currentTaskWaypointCoordinates)
            
        }
    }
}
