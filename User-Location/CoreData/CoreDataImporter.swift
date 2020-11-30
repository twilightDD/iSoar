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
    class func importContent(fromJSONURL: URL) {

        // erhalte data von platte
        
        guard let dataOfJSONFile = ISoarFileManager.dataOfFile(fromJSONURL) else { return }
        
        // mache aus json eine [[ String: Any]]

        let dictionaryOfJSON = ISoarFileManager.dictionaryOfJSONData(data: dataOfJSONFile)
        
        // übergib das dictionary an importgliderModels
        print(dictionaryOfJSON)

     }
    
    class func importDownloadedData(_ data: Data, forType type: FileType) {
            // var for storing Content of Airports.json File as Dictionary
            var jsonAsDict = [String: Any]()
            
            do {
                // Convert Data to Dictionary
                jsonAsDict = try JSONSerialization.jsonObject(with: data,
                                                              options: .allowFragments) as! [String: Any]
                
            } catch {
                print("Could not deserialize JSON")
            }
            
            print("AB HIER IMPORTIEREN")
            
        switch type {
        case .airports:
//            Airport.importOrUpdate(arrayAusDicts)
        break
        case .glidermodels:
//            GliderModel.importOrUpdate(arrayAusDicts)
        break
        default:
            fatalError()
        }
    }
    
    class func importGliderModels(_ dicts: [[String: Any]]) {
        GliderModel.importOrUpdate(dicts)
    }

}
