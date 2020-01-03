//
//  ISoarFileManager.swift
//  Glider Tool
//
//  Created by Peter Hauke on 11.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation

//MARK: - ISoarFileManager
class ISoarFileManager {
    
    //MARK: Private Lets and Vars
    private static let flightSubPath = "/Flights"
    private static let gpxSubPath = "/Tasks"
    
    private static let documentPath: String = {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentPath = dirPaths[0]
        
        return documentPath
    }()
    
    // Path and URL for GPX Files
    private static let gpxPath: String = {
        let gpxPath = documentPath.appending(gpxSubPath)
        
        return gpxPath
    }()
    
    private static let gpxURL: URL = {
        let gpxURL = URL.init(fileURLWithPath: gpxPath)
        
        return gpxURL
    }()
    
    // Path and URL for Flight Files
    private static let flightPath: String = {
        let flightPath = documentPath.appending(flightSubPath)
        
        return flightPath
    }()
    
    private static let flightURL: URL = {
        let flightURL = URL.init(fileURLWithPath: flightPath)
        
        return flightURL
    }()
    
}

//MARK: - Extension - Check Directory Class Methods
// Check if Tasks Folder exists in Documents Folder
extension ISoarFileManager {
    class func checkForTasksFolder() {
        if !FileManager.default.fileExists(atPath: gpxPath) {
            print("Tasks Folder dont exist in Documents Folder. Creating...")
            do {
                try FileManager.default.createDirectory(atPath: gpxPath,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        else {
            print("Tasks Folder exist in Documents Folder.")
        }
    }
    
    // Check if Flights Folder exists in Documents Folder
    class func checkForFlightsFolder() {
        if !FileManager.default.fileExists(atPath: flightPath) {
            print("Flights Folder dont exist in Documents Folder. Creating...")
            do {
                try FileManager.default.createDirectory(atPath: flightPath,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        else {
            print("Flights Folder exist in Documents Folder.")
        }
    }
}

//MARK: - Extension - GPX File Handling
extension ISoarFileManager {
    //MARK:  Public Class Methods
    class func gpxFileNames()
        -> [String] {
            var gpxFileNames = [String]()
            
            // get files from disc
            var fileURLs = [URL]()
            do {
                fileURLs = try FileManager.default.contentsOfDirectory(at: gpxURL,
                                                                       includingPropertiesForKeys: [],
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                fileURLs = fileURLs.filter{ $0.pathExtension == "gpx" }
            }
            catch let contentsOfDirectory {
                fatalError("\(contentsOfDirectory.localizedDescription)")
            }
            
            // parse fileNames
            for fileURL in fileURLs {
                let fileURLWithoutExtension = fileURL.deletingPathExtension()
                let fileName = fileURLWithoutExtension.lastPathComponent
                gpxFileNames.append(fileName)
            }
            
            return gpxFileNames
    }
}

// MARK: - Extension Store Flieght Recorder File
// ToDo: Create Flight Recorder File in Documents Folder
extension ISoarFileManager {
    class func createFlightRecorderFile() {
        
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "yMMdd"
        timeFormatter.dateFormat = "HHmm"
        
        let fileName = "\(dateFormatter.string(from: FlightRecorder.shared.today))-\(timeFormatter.string(from: FlightRecorder.shared.startFlightTime))-\(timeFormatter.string(from: FlightRecorder.shared.stopFlightTime))"
        
        let FlightsDirectory = try? FileManager.default.url(for: .documentDirectory,
                                                            in: .userDomainMask, appropriateFor: nil, create: true)
        
        // ToDo: Store File in Flights Folder instead of Documents Folder
        // If the directory was found, we write a file to it and read it back
        if let fileURL = FlightsDirectory?.appendingPathComponent(fileName).appendingPathExtension("txt") {
            
            // Write Location Data in this file...
            let outString = "Write Location Data in this file when Flight stopped."
            do {
                try outString.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
            
            // Then reading it back from the file
            var inString = ""
            do {
                inString = try String(contentsOf: fileURL)
            } catch {
                print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            }
            print("Read from the file: \(inString)")
        }
    }
}

