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
    
    private static let flightRecorderSubPath = "/Flights"
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
        } catch let getURLError {
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
    private static let flightRecorderDirectoryPath: String = {
        let flightPath = documentPath.appending(flightRecorderSubPath)
        return flightPath
    }()
    
    private static let flightRecorderDirectoryURL: URL = {
        let flightURL = URL.init(fileURLWithPath: flightRecorderDirectoryPath)
        return flightURL
    }()
    
    // MARK: Lets and Vars
    var currentFlightRecordFileHandle: FileHandle?
    var temporaryFlightRecorderFileURL: URL!
    
}

// MARK: - Extension - Check Directory Class Methods
extension ISoarFileManager {
    // Check if Tasks Folder exists in Documents Folder
    class func checkForTasksFolder() {
        if !FileManager.default.fileExists(atPath: gpxPath) {
            print("Tasks Folder dont exist in Documents Folder. Creating...")
            do {
                try FileManager.default.createDirectory(atPath: gpxPath,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("Tasks Folder exist in Documents Folder.")
        }
    }
    
    // Check if Flights Folder exists in Documents Folder
    class func checkForFlightsFolder() {
        if !FileManager.default.fileExists(atPath: flightRecorderDirectoryPath) {
            print("Flights Folder dont exist in Documents Folder. Creating...")
            do {
                try FileManager.default.createDirectory(atPath: flightRecorderDirectoryPath,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("Flights Folder exist in Documents Folder.")
        }
    }
}

// MARK: - Extension - File Handlings
// Extension - GPX File Handling
extension ISoarFileManager {
    // MARK: Public Class Methods
    class func gpxFileNames()
        -> [String] {
            var gpxFileNames = [String]()
            
            // get files from disc
            var fileURLs = [URL]()
            do {
                fileURLs = try FileManager.default.contentsOfDirectory(at: gpxURL,
                                                                       includingPropertiesForKeys: [],
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                fileURLs = fileURLs.filter {$0.pathExtension == "gpx"}
            } catch let contentsOfDirectory {
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
// Create Flight Recorder File in Flights Folder
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
    
    // Get file URLs
    private class func flightMetaDataURLs()
        -> [URL] {
            var fileURLs = [URL]()
            
            do {
                fileURLs = try FileManager.default.contentsOfDirectory(at: flightRecorderDirectoryURL,
                                                                       includingPropertiesForKeys: [],
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                fileURLs = fileURLs.filter {$0.pathExtension == "json"}
            } catch let contentsOfDirectory {
                fatalError("\(contentsOfDirectory.localizedDescription)")
            }
            
            return fileURLs
    }
    
    // Read Content of File
    private class func dataOfFile(_ fileURL: URL)
        -> Data? {
            var fileData: Data?
            
            do {
                fileData = try Data(contentsOf: fileURL)
            } catch let readError {
                print("\(readError.localizedDescription)")
            }
            
            return fileData
    }
    
    // Create JSON for Telemetry Data of current Flight
    // TODO: Replace fatalErrors by userInfo; 05042020, ph
    class func createFlightRecorderFiles()
        -> Bool {

            // TODO: use separate DateFormatter class to deal with times and dates; 05042020, ph
            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            dateFormatter.dateFormat = "y.MM.dd"
            timeFormatter.dateFormat = "HH:mm"
            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
            timeFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?

            // Temporary Flight Recorder File for
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
            let temporaryFileName = UUID().uuidString
            let temporaryFlightRecorderFileURL = temporaryDirectoryURL
                .appendingPathComponent(temporaryFileName)
                .appendingPathExtension("txt") // TODO: use key; 05042020, ph
            shared.temporaryFlightRecorderFileURL = temporaryFlightRecorderFileURL
            
            // Create FlightRecording file as csv
            let outString = "TimeStamp,Latitude,Longitude,Altitude,Speed,Course\n"
            
            var successfullyCreatedFile = false
            do {
                try outString.write(to: temporaryFlightRecorderFileURL,
                                    atomically: true,
                                    encoding: .utf8)
                successfullyCreatedFile = true
            } catch {
                fatalError("Failed writing to URL: \(temporaryFlightRecorderFileURL), Error: " + error.localizedDescription)
            }
            
            do {
                shared.currentFlightRecordFileHandle = try FileHandle.init(forWritingTo: temporaryFlightRecorderFileURL)
                shared.currentFlightRecordFileHandle!.seekToEndOfFile()
            } catch let fileHandleError {
                successfullyCreatedFile = false
                fatalError("No fileHandle: \(fileHandleError.localizedDescription)")
            }


            // Create Meta Data File of flight
            let startTimeFormatted = TimeDateFormatter.yearMonthDayHourMinuteDateFrom(FlightComputer.shared.flightStartTime)
            
            // Create JSON
            let flightMetaData = FlightMetaData.init(flightUUID: FlightComputer.shared.flightUUIDString,
                                                     flightDate: dateFormatter.string(from: startTimeFormatted),
                                                     gliderID: UserDefaultsManager.gliderID(),
                                                     startTimeUTC: timeFormatter.string(from: startTimeFormatted),
                                                     startICAO: FlightComputer.shared.startICAO ?? "----",
                                                     endTimeUTC: "",
                                                     endICAO: "",
                                                     flightCompleted: false,
                                                     flightTime: "")
            
            do {
                let fileURL = flightRecorderDirectoryURL
                    .appendingPathComponent(FlightComputer.shared.flightUUIDString)
                    .appendingPathExtension("json")
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                
                try encoder.encode(flightMetaData)
                    .write(to: fileURL)
                
            } catch let error{
                successfullyCreatedFile = false
                fatalError("\(#function) ERROR: \(error.localizedDescription)")
            }
            
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
    // TODO: Replace fatalErrors by userInfo; 05042020, ph
    class func closeFlightRecorderFiles() {

        // Close Flight Recorder File
        guard let currentFlightRecordFileHandle = shared.currentFlightRecordFileHandle
            else { return }
        currentFlightRecordFileHandle.closeFile()
        shared.currentFlightRecordFileHandle = nil

        // TODO: use separate DateFormatter class to deal with times and dates; 05042020, ph
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "y.MM.dd"
        timeFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        timeFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?

        // Create Final FlightRecorder File
        let finalFlightRecorderFileURL = flightRecorderDirectoryURL
            .appendingPathComponent(FlightComputer.shared.flightUUIDString)
            .appendingPathExtension("txt")

        do {
            try FileManager.default.moveItem(at: shared.temporaryFlightRecorderFileURL,
                                             to: finalFlightRecorderFileURL)
            // TODO: remove temporary file; 05042020, ph
        } catch {
            fatalError("Failed writing to URL: \(String(describing: finalFlightRecorderFileURL)), Error: " + error.localizedDescription)
        }


        // Update  Meta Data File of flight
        let startTimeFormatted = TimeDateFormatter.yearMonthDayHourMinuteDateFrom(FlightComputer.shared.flightStartTime)
        let endTimeFormatted =  TimeDateFormatter.yearMonthDayHourMinuteDateFrom(FlightComputer.shared.flightEndTime)
        let flightTime = TimeDateFormatter.hourMinutesStringFrom(startTime: startTimeFormatted,
                                                                 toEndTime: endTimeFormatted)
        
        let flightMetaData = FlightMetaData(flightUUID: FlightComputer.shared.flightUUIDString,
                                            flightDate: (dateFormatter.string(from: startTimeFormatted)),
                                            gliderID: UserDefaultsManager.gliderID(),
                                            startTimeUTC: (timeFormatter.string(from: startTimeFormatted)),
                                            startICAO: FlightComputer.shared.startICAO ?? "----",
                                            endTimeUTC: (timeFormatter.string(from: endTimeFormatted)),
                                            endICAO: FlightComputer.shared.endICAO ?? "----",
                                            flightCompleted: true,
                                            flightTime: flightTime)
        
        do {
            let flightMetaDataFileURL = flightRecorderDirectoryURL
                .appendingPathComponent(FlightComputer.shared.flightUUIDString)
                .appendingPathExtension("json")
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            try encoder.encode(flightMetaData)
                .write(to: flightMetaDataFileURL)
            
        } catch let error {
            fatalError("\(#function) ERROR: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Extension Read GPX File
    // Read Content of GPX File
    class func readContentOfSelectedGPXfile(_ fileName: String)
        -> Data? {
            //Convert the fileName to a computer readable filepath
            let fileURL = ISoarFileManager.gpxURL.appendingPathComponent(fileName).appendingPathExtension("gpx")
            
            let fileData = dataOfFile(fileURL)
            
            return fileData
            
    }
    
}
