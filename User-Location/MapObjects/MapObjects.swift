//
//  MapObjects.swift
//  Glider Tool
//
//  Created by Peter Hauke on 02.06.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation
import CoreLocation

class MapObjects{
    
    static let shared = MapObjects()
    var destinationAirports = [MapObjects.Airport]()
    
    let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
    
    struct Airport {
        var valid:String
        var icao:String
        var name:String
        var latitude:Double
        var longitude:Double
        var elevation:Double
        var airportType:String
        var runwaySurface:String
        var runwayDimensions:String
        var runways:String
        var url:String?
        var country:String?
        var distance:CLLocationDistance?
        
        // var radios:[Radio] // hinzufügen => ProTipp: Struct ;)
        
        //MARK: - Public Init & Co.
        public init(dictionary: Dictionary<String, Any>) {
            self.valid = dictionary["valid"] as? String ?? ""
            self.icao = dictionary["icao"] as? String ?? ""
            self.name = dictionary["name"] as? String ?? ""
            self.latitude = dictionary["latitude"] as? Double ?? 0
            self.longitude = dictionary["longitude"] as? Double ?? 0
            self.elevation = dictionary["elevation"] as? Double ?? 0
            self.airportType = dictionary["airportType"] as? String ?? ""
            self.runwaySurface = dictionary["runwaySurface"] as? String ?? ""
            self.runwayDimensions = dictionary["runwayDimensions"] as? String ?? ""
            self.runways = dictionary["runways"] as? String ?? ""
            self.url = dictionary["url"] as? String ?? ""
            self.country = dictionary["country"] as? String ?? ""
        }
        
        mutating func updateDistance(_ newDistance:CLLocationDistance) {
            distance = newDistance
        }
    }
    
    //MARK: - Private Init & Co.
    private init(){
        checkForMapOjectsInDocumentsFolder()
        loadAirports()
    }
    
    // MARK: - Functions
    // Check if MapOjects.json exists in Documents Folder
    func checkForMapOjectsInDocumentsFolder() {
        // Check if MapObjects.json exists in Documents Folder
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
 
        let destinationFileUrl = documentsUrl.appendingPathComponent("MapObjects.json")
        let mapObjectsURL = URL(fileURLWithPath: Bundle.main.path(forResource: "MapObjects", ofType: "json")!)
        
        if let pathComponent = url.appendingPathComponent("MapObjects.json") {
            
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("MapObjects available")
            } else {
                print("MapObjects not found in Documents Folder... will copy...")
                do {
                try FileManager.default.copyItem(at: mapObjectsURL, to: destinationFileUrl)
                print("MapObjects copied to Documents Folder.")
                } catch (let writeError) {
                    print("Error creating a file: \(destinationFileUrl) : \(writeError)")
                }
            }
        }
    }
    
    // Request for Location
    func requestForLocation(){
        //Code Process
        print("Location granted")
    }
    
    // Load Airports
    func loadAirports() {
        // --- json laden
        
        // hier kommt der Inhalt der Datein rein
        var jsonAsString:String?

        let mapObjectsURL = documentsUrl.appendingPathComponent("MapObjects.json")
        
        do {
            // URL laden und als String zurück geben
            try jsonAsString = String.init(contentsOf: mapObjectsURL)
        }
        catch {
            print("went wrong")
        }
        
        // String in Data konvertieren
        let jsonAsData = jsonAsString?.data(using: .utf8)
        
        // hier kommt der Inhalt der Datei als Dictionary rein
        var jsonAsDict = [String:Any]()
        do {
            // Umwandeln des Data in ein Dictionary (nennt sich deserialisieren)
            jsonAsDict = try JSONSerialization.jsonObject(with: jsonAsData!,
                                                          options: .allowFragments) as! [String : Any]
        }
        catch {
            print("json went wrong")
        }
        
        // --- Dict parsen und Annotations bauen
        // Airports
        // aus dem Dictionary den Zweig für 'Airports holen (sollte ein Array sein)
        
        if let airports = jsonAsDict["Airports"] as? [Dictionary<String, Any>] {
            // jedes Element des Arrays abklappern
            for airport in airports {
                let myAirportStruct = MapObjects.Airport(dictionary: airport)
                destinationAirports.append(myAirportStruct)
            }
        }
    }
}
