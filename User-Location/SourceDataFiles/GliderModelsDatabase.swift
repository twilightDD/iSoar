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
    private static let shared = GliderModelsDatabase()
    
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
                
                //shared.loadGliderModelsFromJSONIntoDatabase()
                
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

}
