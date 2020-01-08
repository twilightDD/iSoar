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
    private static let shared = ISoarFileManager()

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

    //Mark: Lets and Vars
    var currentFlightRecordFileHandle: FileHandle?




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

// MARK: - Extension Store Flight Recorder File
// ToDo: Create Flight Recorder File in Documents Folder
extension ISoarFileManager {
    class func createFlightRecorderFile() {
        
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "yMMdd"
        timeFormatter.dateFormat = "HHmm"
        
        let fileName = "\(dateFormatter.string(from: FlightRecorder.shared.today))-\(timeFormatter.string(from: FlightRecorder.shared.startFlightTime))-\(timeFormatter.string(from: FlightRecorder.shared.stopFlightTime))"

        let fileURL = flightURL.appendingPathComponent(fileName).appendingPathExtension("txt")

        // Write Location Data in this file...
        let outString = "Write IGC valid Data in here... later..."
        do {
            try outString.write(to: fileURL,
                                atomically: true,
                                encoding: .utf8)
        } catch {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }


    class func createFileForFlight()
        -> Bool {

            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            dateFormatter.dateFormat = "yMMdd"
            timeFormatter.dateFormat = "HHmm"

            let fileName = "\(dateFormatter.string(from: FlightRecorder.shared.today))-\(timeFormatter.string(from: FlightRecorder.shared.startFlightTime))"

            let fileURL = flightURL.appendingPathComponent(fileName).appendingPathExtension("txt")

            // Write Location Data in this file...
            let outString = "FileName: \(fileName)\n"

            var successfullyCreatedFile = false
            do {
                try outString.write(to: fileURL,
                                    atomically: true,
                                    encoding: .utf8)
                successfullyCreatedFile = true
            } catch {
                fatalError("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }


            do {
                shared.currentFlightRecordFileHandle = try FileHandle.init(forWritingTo: fileURL)
                shared.currentFlightRecordFileHandle!.seekToEndOfFile()
            }
            catch let fileHandleError {
                fatalError("No fileHandle: \(fileHandleError.localizedDescription)")
            }


            return successfullyCreatedFile

    }

    @discardableResult
    class func appendToFlightRecorderFile(_ string: String)
        -> Bool {
            guard let fileHandle = shared.currentFlightRecordFileHandle
                else { return false }
            guard let stringData = string.data(using: .utf8)
                else { return false }

            fileHandle.write(stringData)

            return true
    }

    class func stopFlightRecorderFile() {
        guard let fileHandle = shared.currentFlightRecordFileHandle
            else { return }

        fileHandle.closeFile()
        shared.currentFlightRecordFileHandle = nil

        // Datei umbenennen
        // alte fileURL nehmen - um Endzeit den Dateinamen dieser fileURL ergänzen - Datei umbennen (move)

    }

}

