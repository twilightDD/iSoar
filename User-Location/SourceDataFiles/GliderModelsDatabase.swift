//
//  GliderModelsDatabase.swift
//  Glider Tool
//
//  Created by sonic on 17.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import CoreData

class GliderModelsDatabase {
    // MARK: - Lets and Vars
    // Static
    static private let shared = GliderModelsDatabase()
    
    // Private
    private let libraryURL: URL =  (FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first as URL?)!
    
    // MARK: - Init&Co.
    private init() {
        checkForGliderModelsJSONInLibraryFolder()
    }
    
    // MARK: - Public Class Methods
    // Check if Entity is empty
    class func entityIsEmpty(entity: String) {
        do {
            let context = CoreDataManager.viewOnlyContext
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
            let count = try context.count(for: request)
            
            if count < 1 {
                print("OBJEKTE IN ENTITY \(entity): \(count) - WE HAVE TO IMPORT DATA")
                
            } else {
                print("OBJEKTE IN ENTITY \(entity): \(count)")
            }
            
        } catch {
            print("ERROR")
        }
        
    }
    
    // MARK: - Private Methods
    // Check if private init().json exists in Library Folder
    private func checkForGliderModelsJSONInLibraryFolder() {
        // Check if private init().json exists in Library Folder
        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        
        let gliderModelsJSONInLibraryFolder = libraryURL.appendingPathComponent("GliderModels.json")
        let gliderModelsJSONInBundle = URL(fileURLWithPath: Bundle.main.path(forResource: "GliderModels", ofType: "json")!)
        
        if let pathComponent = url.appendingPathComponent("GliderModels.json") {
            
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("GliderModels.json available in Library Folder.")
            } else {
                print("GliderModels.json not found in Library Folder. Copy...")
                do {
                    try FileManager.default.copyItem(at: gliderModelsJSONInBundle, to: gliderModelsJSONInLibraryFolder)
                    print("GliderModels.json copied to Library Folder.")
                } catch let writeError {
                    print("Error creating a file: \(gliderModelsJSONInLibraryFolder) : \(writeError)")
                }
            }
        }
    }
    
    // Load GliderModels from GliderModels.json into Database
    private func loadGliderModelsFromJSONIntoDatabase() {
        // var for storing Content of GliderModels.json File
        var jsonAsString: String?
        
        // TODO: 20201121 Fehlerbehandlung! wenn .json nicht vorhanden, guard let
        let gliderModelsURL = libraryURL.appendingPathComponent("GliderModels.json")
        
        do {
            // Storing Content of Airports.json File as String
            try jsonAsString = String.init(contentsOf: gliderModelsURL)
        } catch {
            print("went wrong")
        }
        
        // Convert String to Data
        let jsonAsData = jsonAsString?.data(using: .utf8)
        
        // var for storing Content of GliderModels.json File as Dictionary
        var jsonAsDict = [String: Any]()
        
//        do {
//            // Convert Data to Dictionary
//            jsonAsDict = try JSONSerialization.jsonObject(with: jsonAsData!,
//                                                          options: .allowFragments) as! [String: Any]
//        } catch {
//            // TODO: 20201121 Fehlerbehandlung! wenn .json fehlerhaft
//            NotificationBanner.show("Airport Database not found.")
//        }
//
//        if let airports = jsonAsDict["Airports"] as? [[String: Any]] {
//            // Append every single Object to Airports Database
//            for airport in airports {
//                let myAirportStruct = AirportDatabase.Airport(dictionary: airport)
//                destinationAirports.append(myAirportStruct)
//            }
//        }
    }

}
