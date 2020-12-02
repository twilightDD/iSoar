//
//  CoreDataImporter.swift
//  Glider Tool
//
//  Created by sonic on 25.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

class CoreDataImporter {
    
    // MARK: - Lets and Vars
    // Static
    static  let shared = CoreDataImporter()
    
    // MARK: - Public Class Methods
    class func initalImport() {
        // Airports
        if let airportFileContent = ISoarFileManager.dataFor(type: .airports) {
            importData(airportFileContent, forType: .airports)
        }
        
        // GliderModels
        if let gliderModelFileContent = ISoarFileManager.dataFor(type: .glidermodels) {
            importData(gliderModelFileContent, forType: .glidermodels)
        }
        
    }
    
    class func importData(_ data: Data, forType type: ContentType) {
        guard let dict = DLJSON.decode(data)
        else { return }
        
        switch type {
        case .airports:
            if let airports = dict["Airports"] as? [[String: Any]] {
                importAirports(airports)
            }
        case .glidermodels:
            if let gliderModels = dict["GliderModels"] as? [[String: Any]] {
                importGliderModels(gliderModels)
            }
            
        }
    }
    
    class func importAirports(_ dictionaries: [[String: Any]]) {
        Airport.importOrUpdate(dictionaries)
    }
    
    class func importGliderModels(_ dictionaries: [[String: Any]]) {
        GliderModel.importOrUpdate(dictionaries)
    }
    
}
