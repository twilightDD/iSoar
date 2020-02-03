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
    
    private static let documentDirectoryURL: URL = {
        do {
            let url = try FileManager.default.url(for: .documentDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: false)
            return url
        }
        catch let getURLError {
            fatalError("\(getURLError.localizedDescription)")
        }
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


// MARK: - Extension Store Flight Recorder File
// ToDo: Create Flight Recorder File in Flights Folder
extension ISoarFileManager {
    class func flightMetaDataFileDatas()
        -> [Data] {
            var flightMetaDataFileDatas = [Data]()
            
            let metaDataFileURLs = flightMetaDataURLs()
            for metaDataFileURL in metaDataFileURLs {
                if let fileData = dataOfFile(metaDataFileURL) {
                    flightMetaDataFileDatas.append(fileData)
                }
            }
            
            return flightMetaDataFileDatas
    }
    
    
    private class func flightMetaDataURLs()
        -> [URL] {
            var fileURLs = [URL]()
            
            do {
                fileURLs = try FileManager.default.contentsOfDirectory(at: flightURL,
                                                                       includingPropertiesForKeys: [],
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                fileURLs = fileURLs.filter{ $0.pathExtension == "json" }
            }
            catch let contentsOfDirectory {
                fatalError("\(contentsOfDirectory.localizedDescription)")
            }
            
            return fileURLs
    }
    
    
    private class func dataOfFile(_ fileURL: URL)
        -> Data? {
            var flightMetaDataFileData: Data?
            
            do {
                flightMetaDataFileData = try Data(contentsOf: fileURL)
            } catch let readError {
                print("\(readError.localizedDescription)")
            }
            
            return flightMetaDataFileData
    }
    
    class func createFlightRecorderFiles()
        -> Bool {
            
            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            dateFormatter.dateFormat = "y.MM.dd"
            timeFormatter.dateFormat = "HH:mm"
            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
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
            
            
            let startTimeFormatted = TimeDateFormatter.yearMonthDayHourMinuteDateFrom(FlightComputer.shared.flightStartTime)
            
            // Create JSON
            let data = FlightMetaData.init(flightUUID: FlightComputer.shared.flightUUIDString,
                                           flightDate: (dateFormatter.string(from: startTimeFormatted)),
                                           gliderID: UserDefaultsManager.getGliderID(),
                                           startTimeUTC: (timeFormatter.string(from: startTimeFormatted)),
                                           startICAO: FlightComputer.shared.startICAO ?? "----",
                                           endTimeUTC: "",
                                           endICAO: "",
                                           flightCompleted: false,
                                           flightTime: "")
            
            
            do {
                let fileURL = flightURL.appendingPathComponent(FlightComputer.shared.flightUUIDString).appendingPathExtension("json")
                
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
    
    // Close Flight Recorder Files
    class func closeFlightRecorderFiles() {
        guard let fileHandle = shared.currentFlightRecordFileHandle
            else { return }
        
        // Close Flight Telemetry Data File
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "y.MM.dd"
        timeFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        timeFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        
        // Set Final Flight Recorder FileNameURL
        ISoarFileManager.shared.finalRecorderFileURL = flightURL.appendingPathComponent(FlightComputer.shared.flightUUIDString).appendingPathExtension("txt")
        
        fileHandle.closeFile()
        shared.currentFlightRecordFileHandle = nil
        
        do {
            try FileManager.default.moveItem(at: ISoarFileManager.shared.tempRecorderFileURL,
                                             to: ISoarFileManager.shared.finalRecorderFileURL)
        } catch {
            fatalError("Failed writing to URL: \(String(describing: ISoarFileManager.shared.finalRecorderFileURL)), Error: " + error.localizedDescription)
        }
        
        // Create JSON
        let startTimeFormatted = TimeDateFormatter.yearMonthDayHourMinuteDateFrom(FlightComputer.shared.flightStartTime)
        let endTimeFormatted =  TimeDateFormatter.yearMonthDayHourMinuteDateFrom(FlightComputer.shared.flightEndTime)
        
        let flightTime = TimeDateFormatter.hourMinutesStringFrom(startTime: startTimeFormatted,
                                                                 toEndTime: endTimeFormatted)
        
        let data = FlightMetaData(flightUUID: FlightComputer.shared.flightUUIDString,
                                  flightDate: (dateFormatter.string(from: startTimeFormatted)),
                                  gliderID: UserDefaultsManager.getGliderID(),
                                  startTimeUTC: (timeFormatter.string(from: startTimeFormatted)),
                                  startICAO: FlightComputer.shared.startICAO ?? "----",
                                  endTimeUTC: (timeFormatter.string(from: endTimeFormatted)),
                                  endICAO: FlightComputer.shared.endICAO ?? "----",
                                  flightCompleted: true,
                                  flightTime: flightTime)
        
        do {
            let fileURL = flightURL.appendingPathComponent(FlightComputer.shared.flightUUIDString).appendingPathExtension("json")
            
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
