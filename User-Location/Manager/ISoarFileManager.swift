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
    
    // MARK: - Keys
    private static let csvPathExtension = "csv"
    private static let gpxPathExtension = "gpx"
    private static let jsonPathExtension = "json"
    
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
    var temporaryFlightRecorderFileURL: URL?
    
}

// MARK: - Extension - Check Directory Class Methods
extension ISoarFileManager {
    
    // MARK: Public Class Methods
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

// MARK: - Extension -  GPX File Handling
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
                fileURLs = fileURLs.filter {$0.pathExtension == gpxPathExtension}
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
    
    class func readContentOfSelectedGPXfile(_ fileName: String)
        -> Data? {
            
            let fileURL = ISoarFileManager.gpxURL
                .appendingPathComponent(fileName)
                .appendingPathExtension(gpxPathExtension)
            
            let fileData = dataOfFile(fileURL)
            
            return fileData
            
    }
}

// MARK: - Extension Store Flight Recorder File
// Create Flight Recorder File in Flights Folder
extension ISoarFileManager {
    
    // MARK: Public Class Methods
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
                fileURLs = try FileManager.default.contentsOfDirectory(at: flightRecorderDirectoryURL,
                                                                       includingPropertiesForKeys: [],
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                fileURLs = fileURLs.filter {$0.pathExtension == jsonPathExtension}
            } catch let contentsOfDirectory {
                fatalError("\(contentsOfDirectory.localizedDescription)")
            }
            
            return fileURLs
    }
    
    // Create JSON for Telemetry Data of current Flight
    // TODO: Replace fatalErrors by userInfo; 05042020, ph
    class func createFlightRecorderFiles(flightUUIDString: String,
                                         flightStartDate: Date,
                                         startICAO: String?)
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
            let temporaryFlightRecorderFileURL = temporaryDirectoryURL
                .appendingPathComponent(flightUUIDString)
                .appendingPathExtension(csvPathExtension)
            
            shared.temporaryFlightRecorderFileURL = temporaryFlightRecorderFileURL
            
            // Create FlightRecording file as csv
            var successfullyCreatedFile = false
            do {
                let csvHeaderString = "TimeStamp,Latitude,Longitude,Altitude,Speed,Course\n"
                try csvHeaderString.write(to: temporaryFlightRecorderFileURL,
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
            // let flightDatas = FlightComputer.flightDatas()
            let startTimeFormatted = TimeDateFormatter.yearMonthDayHourMinuteDateFrom(flightStartDate)
            
            // Create JSON
            let flightMetaData = FlightMetaData.init(flightUUID: flightUUIDString,
                                                     flightDate: dateFormatter.string(from: startTimeFormatted),
                                                     gliderID: UserDefaultsManager.gliderID(),
                                                     startTimeUTC: timeFormatter.string(from: startTimeFormatted),
                                                     startICAO: startICAO ?? "----",
                                                     endTimeUTC: "",
                                                     endICAO: "",
                                                     flightCompleted: false,
                                                     flightTime: "")
            
            do {
                let fileURL = flightRecorderDirectoryURL
                    .appendingPathComponent(flightUUIDString)
                    .appendingPathExtension(jsonPathExtension)
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                
                try encoder.encode(flightMetaData)
                    .write(to: fileURL)
                
            } catch let error {
                successfullyCreatedFile = false
                fatalError("\(#function) ERROR: \(error.localizedDescription)")
            }
            
            // TODO: if file creation fails at any level, remove temp file an meta data file; 05042020, ph
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
    class func closeFlightRecorderFiles(flightUUIDString: String,
                                        flightStartDate: Date,
                                        flightEndDate: Date,
                                        startICAO: String?,
                                        endICAO: String?) {
        
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
            .appendingPathComponent(flightUUIDString)
            .appendingPathExtension(csvPathExtension)
        
        do {
            guard let temporaryFlightRecorderFileURL = shared.temporaryFlightRecorderFileURL
                else { fatalError() }
            try FileManager.default.moveItem(at: temporaryFlightRecorderFileURL,
                                             to: finalFlightRecorderFileURL)
            // TODO: remove temporary file here; 05042020, ph
        } catch {
            fatalError("Failed writing to URL: \(String(describing: finalFlightRecorderFileURL)), Error: " + error.localizedDescription)
        }
        
        // Update Meta Data File of flight
        let startTimeFormatted = TimeDateFormatter.yearMonthDayHourMinuteDateFrom(flightStartDate)
        let endTimeFormatted =  TimeDateFormatter.yearMonthDayHourMinuteDateFrom(flightEndDate)
        let flightTime = TimeDateFormatter.hourMinutesStringFrom(startTime: startTimeFormatted,
                                                                 toEndTime: endTimeFormatted)
        
        let flightMetaData = FlightMetaData(flightUUID: flightUUIDString,
                                            flightDate: (dateFormatter.string(from: startTimeFormatted)),
                                            gliderID: UserDefaultsManager.gliderID(),
                                            startTimeUTC: (timeFormatter.string(from: startTimeFormatted)),
                                            startICAO: startICAO ?? "----",
                                            endTimeUTC: (timeFormatter.string(from: endTimeFormatted)),
                                            endICAO: endICAO ?? "----",
                                            flightCompleted: true,
                                            flightTime: flightTime)
        
        do {
            let flightMetaDataFileURL = flightRecorderDirectoryURL
                .appendingPathComponent(flightUUIDString)
                .appendingPathExtension(jsonPathExtension)
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            try encoder.encode(flightMetaData)
                .write(to: flightMetaDataFileURL)
            
        } catch let error {
            fatalError("\(#function) ERROR: \(error.localizedDescription)")
        }
    }
    
    // TODO: Check Syntax with ph
    // Delete Flight Files in Flights Folder
    class func deleteFlightFiles(_ flightUUID: String) {
        
        let jsonPath: String = "\(flightRecorderDirectoryPath)/\(flightUUID).\(jsonPathExtension)"
        let csvPath: String = "\(flightRecorderDirectoryPath)/\(flightUUID).\(csvPathExtension)"
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: jsonPath) {
            do {
                try fileManager.removeItem(atPath: jsonPath)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        if fileManager.fileExists(atPath: csvPath) {
            do {
                try fileManager.removeItem(atPath: csvPath)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Extension - General Helper Methods
extension ISoarFileManager {
    
    // MARK: Public Class Methods
    
    // MARK: Private Class Methods
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
    
}
