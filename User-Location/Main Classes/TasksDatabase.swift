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
class TasksDatabase {
    
    // MARK: - Lets and Vars
    static let shared = TasksDatabase()
    
    // TODO: only init! remove content! only for testing Task Lines
    var currentTaskWaypointCoordinates = [
        CLLocationCoordinate2D(latitude: 47.802914, longitude: 8.97955),
        CLLocationCoordinate2D(latitude: 48, longitude: 8.85),
        CLLocationCoordinate2D(latitude: 47.96, longitude: 9.1),
        CLLocationCoordinate2D(latitude: 47.802914, longitude: 8.97955)
    ]
    
    class func gpxFileNames()
        -> [String] {
            let gpxFileNames = ISoarFileManager.gpxFileNames()
            
            return gpxFileNames
    }
    
}

// MARK: - Private Methods
// Read Content of GPX File
//func readGPXfile() {
//    //Convert the fileName to a computer readable filepath
//    let filePath = getFilePath(fileName)
//
//    if filePath == nil {
//        print ("File \"\(fileName).gpx\" does not exist in the project. Please make sure you imported the file and dont have any spelling errors")
//        continue
//    }
//
//    //Setup the parser and initialize it with the filepath's data
//    let data = NSData(contentsOfFile: filePath!)
//    let parser = XMLParser(data: data!)
//    parser.delegate = self
//
//    //Parse the data, here the file will be read
//    let success = parser.parse()
//
//    //Log an error if the parsing failed
//    if !success {
//        print ("Failed to parse the following file: \(fileName).gpx")
//    }
//    
//}

// Parse Content for Latitude and Longitude
func parseContent(parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: Double]) {
    //Check for the lines that have a <trkpt> or <wpt> tag
    if elementName == "trkpt" || elementName == "wpt" {
        //Create a World map coordinate from the file
        let waypointLatitude = attributeDict["lat"]!
        let waypointLongitude = attributeDict["lon"]!
        
        TasksDatabase.shared.currentTaskWaypointCoordinates.append(CLLocationCoordinate2D(latitude: waypointLatitude, longitude: waypointLongitude))
    }
    
}

// MARK: - Extentsion - Structs and Enums

//extension TasksDatabase {

struct Waypoint: Equatable {
    // MARK: Lets and Vars
    var latitude: String
    var longitude: String
    
}
