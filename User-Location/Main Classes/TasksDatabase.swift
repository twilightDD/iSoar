//
//  TasksDatabase.swift
//  Glider Tool
//
//  Created by sonic on 06.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation
import CoreLocation


protocol TasksDatabaseProtocol: AnyObject {

    func newTask(withCoordinates coordinates: [CLLocationCoordinate2D])

}

// MARK: - TasksDatabase
class TasksDatabase: NSObject {
    
    // MARK: - Lets and Vars
    // Static
    private static let shared = TasksDatabase()

    // Public
    weak var delegate: TasksDatabaseProtocol?

    // Private
    private var taskWaypoints = [CLLocationCoordinate2D]()

    // MARK: - Class Methods

    class func registerForTaskUpdates(_ delegate: TasksDatabaseProtocol) {
        shared.delegate = delegate
    }

    class func unRegisterForTaskUpdates() {
        shared.delegate = nil
    }

    class func gpxFileNames()
        -> [String] {
            let gpxFileNames = ISoarFileManager.gpxFileNames()
            
            return gpxFileNames
    }

    class func noGPXFileSelected() {
        shared.taskWaypoints.removeAll()
        shared.delegate?.newTask(withCoordinates: shared.taskWaypoints)
    }

    class func openGPXFile(withFilename fileName: String) {
        shared.openGPXFile(withFilename: fileName)
    }

    // MARK: - Private Methods
    private func openGPXFile(withFilename fileName: String) {
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

// MARK: - Extension - XMLParserDelegate
extension TasksDatabase: XMLParserDelegate {

    // parser start
    func parserDidStartDocument(_ parser: XMLParser) {
        taskWaypoints.removeAll()
        delegate?.newTask(withCoordinates: taskWaypoints) // empty array!
    }

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
                taskWaypoints.append(waypointCoordinate)
            }
        }
    }

    // Parser end
    func parserDidEndDocument(_ parser: XMLParser) {
        delegate?.newTask(withCoordinates: taskWaypoints)
    }

}
