//
//  ISoarFileManager.swift
//  Glider Tool
//
//  Created by Peter Hauke on 11.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//
//

import Foundation

// MARK: - ISoarFileManager
class ISoarFileManager {
    
    // MARK: Private Lets and Vars
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
    
    // MARK: Lets and Vars
    var currentFlightRecordFileHandle: FileHandle?
    
    var tempRecorderFileURL: URL!
    var finalRecorderFileURL: URL!
    
}

// MARK: Extension - Struct

struct flightMetadata: Codable {
    var uuid: String
    var date: String
    var gliderID: String
    var startTimeUTC: String
    var startICAO: String
    var endTimeUTC: String
    var endICAO: String
    var flightCompleted: Bool
    var flightTime: String
}

// MARK: - Extension - Check Directory Class Methods
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

// MARK: - Extension - File Handlings
// Extension - GPX File Handling
extension ISoarFileManager {
    // MARK:  Public Class Methods
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

// Extension - Flight File Handling
extension ISoarFileManager {
    // MARK:  Public Class Methods
    class func flightFileNames()
        -> [String] {
            var flightFileNames = [String]()
            
            // get files from disc
            var fileURLs = [URL]()
            do {
                fileURLs = try FileManager.default.contentsOfDirectory(at: flightURL,
                                                                       includingPropertiesForKeys: [],
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                fileURLs = fileURLs.filter{ $0.pathExtension == "txt" }
            }
            catch let contentsOfDirectory {
                fatalError("\(contentsOfDirectory.localizedDescription)")
            }
            
            // parse fileNames
            for fileURL in fileURLs {
                let fileURLWithoutExtension = fileURL.deletingPathExtension()
                let fileName = fileURLWithoutExtension.lastPathComponent
                flightFileNames.append(fileName)
            }
            
            return flightFileNames
    }
}

// MARK: - Extension Store Flight Recorder File
// ToDo: Create Flight Recorder File in Flights Folder
extension ISoarFileManager {
    class func createFlightRecorderFile()
        -> Bool {
            
            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            dateFormatter.dateFormat = "y-MM-dd"
            timeFormatter.dateFormat = "HH:mm"
            timeFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
            
            let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
            let uuidFileName = UUID().uuidString
            
            let tempFileURL = tempDirURL.appendingPathComponent(uuidFileName).appendingPathExtension("txt")
            
            ISoarFileManager.shared.tempRecorderFileURL = tempFileURL
            
            // Write Telemetry Data to Flight Recorder File
            let outString = "TimeStamp,Latitude,Longitude,Altitude,Speed,Course\n"
            
            var successfullyCreatedFile = false
            do {
                try outString.write(to: tempFileURL,
                                    atomically: true,
                                    encoding: .utf8)
                successfullyCreatedFile = true
            } catch {
                fatalError("Failed writing to URL: \(tempFileURL), Error: " + error.localizedDescription)
            }
            
            do {
                shared.currentFlightRecordFileHandle = try FileHandle.init(forWritingTo: tempFileURL)
                shared.currentFlightRecordFileHandle!.seekToEndOfFile()
            }
            catch let fileHandleError {
                fatalError("No fileHandle: \(fileHandleError.localizedDescription)")
            }
            
            

            
            // Create JSON
            let data = flightMetadata(uuid: "uuid",
                                      date: (dateFormatter.string(from: FlightComputer.shared.flightStartTime)),
                                      gliderID: UserDefaultsManager.getGliderID(),
                startTimeUTC: "\(timeFormatter.string(from: FlightComputer.shared.flightStartTime)) UTC",
                startICAO: "",
                endTimeUTC: "",
                endICAO: "",
                flightCompleted: false,
                flightTime: "")
            
            do {
                let fileURL = try FileManager.default
                    .url(for: .documentDirectory,
                         in: .userDomainMask,
                         appropriateFor: nil,
                         create: true)
                    .appendingPathComponent("MyFile.json")
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                
                try encoder.encode(data)
                    .write(to: fileURL)
                
            } catch {
                fatalError()
            }
            // End Create JSON
            
            
            
            
            
            

            
            return successfullyCreatedFile
            
    }
    
    @discardableResult
    class func appendTelemetryDataToFlightRecorderFile(_ string: String)
        -> Bool {
            guard let fileHandle = shared.currentFlightRecordFileHandle
                else { return false }
            guard let stringData = string.data(using: .utf8)
                else { return false }
            
            fileHandle.write(stringData)
            
            return true
    }
    
    // Close Flight Recorder File
    class func closeFlightRecorderFile() {
        guard let fileHandle = shared.currentFlightRecordFileHandle
            else { return }
        
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd"
        timeFormatter.dateFormat = "HHmm"
        timeFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        
        // Set Final Flight Recorder FileNameURL
        ISoarFileManager.shared.finalRecorderFileURL = flightURL.appendingPathComponent("\(dateFormatter.string(from: FlightComputer.shared.flightStartTime)) \(timeFormatter.string(from: FlightComputer.shared.flightStartTime))-\(timeFormatter.string(from: FlightComputer.shared.flightEndTime))").appendingPathExtension("txt")
        
        fileHandle.closeFile()
        shared.currentFlightRecordFileHandle = nil
        
        do {
            try FileManager.default.moveItem(at: ISoarFileManager.shared.tempRecorderFileURL,
                                             to: ISoarFileManager.shared.finalRecorderFileURL)
        } catch {
            fatalError("Failed writing to URL: \(String(describing: ISoarFileManager.shared.finalRecorderFileURL)), Error: " + error.localizedDescription)
        }
        
        print(ISoarFileManager.shared.finalRecorderFileURL)
        
        
        
        
        // Read back from JSON File
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: false)
                .appendingPathComponent("MyFile.json")

            let data = try Data(contentsOf: fileURL)
            let metaData = try JSONDecoder().decode(flightMetadata.self,
                                               from: data)
            print(metaData)
        } catch {
            print(error)
        }
        // Done
        
        // Create JSON
        let data = flightMetadata(uuid: "uuid",
                                  date: (dateFormatter.string(from: FlightComputer.shared.flightStartTime)),
                                  gliderID: UserDefaultsManager.getGliderID(),
            startTimeUTC: "\(timeFormatter.string(from: FlightComputer.shared.flightStartTime)) UTC",
            startICAO: "",
            endTimeUTC: "\(timeFormatter.string(from: FlightComputer.shared.flightEndTime)) UTC",
            endICAO: "",
            flightCompleted: true,
            flightTime: "")
        
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("MyFile.json")
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            try encoder.encode(data)
                .write(to: fileURL)
            
        } catch {
            fatalError()
        }
        // End Create JSON
        
        
        
        
        
        
        
    }
    
}
