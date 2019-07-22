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
        
        // var radios:[Radio] // hinzufügen => ProTipp: Struct ;)
        
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
    }
    
    struct RestrictedAreas {
        // vars
        
        // public init
    }
    
    
    private init(){
        self.loadMapAnnotations()
    }
    
    func requestForLocation(){
        //Code Process
        print("Location granted")
    }
    func loadMapAnnotations() {
        // --- json laden
        
        // hier kommt der Inhalt der Datein rein
        var jsonAsString:String?
        
        // Dateipfad holen
        guard let mapObjectsPath = Bundle.main.path(forResource: "MapObjects",
                                                    ofType: "json")
            else { return }
        
        // aus Pfad eine URL machen
        let mapObjectsURL = URL(fileURLWithPath: mapObjectsPath)
        
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
        
        // RestrictedAreas
        if let restrictedAreas:[NSDictionary] = jsonAsDict["RestrictedAreas"] as? [NSDictionary] {
            // jedes Element des Arrays abklappern
            for restrictedArea in restrictedAreas {
                
                // Coordinates rauskramen und in ein Array packen
                if let coordinatesFromDict:[NSDictionary] = restrictedArea["geoPoints"] as? [NSDictionary] {
                    var locationCoordinates:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
                    for coordinate in coordinatesFromDict {
                        guard let latitude = coordinate["latitude"] as? Double,
                            let longitude = coordinate["longitude"] as? Double
                            else { break }
                        locationCoordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    }
                    
                    // Polyline erzeugen
                    let restrictedAreaPolyline = DLPolyline(coordinates: locationCoordinates,
                                                            count: UInt(locationCoordinates.count))
                    
                    // restricted area type
                    if let typeString = restrictedArea["type"] as? String {
                        switch typeString {
                        case "C":
                            restrictedAreaPolyline.type = .restrictedAreaC
                        case "CTR":
                            restrictedAreaPolyline.type = .restrictedAreaCTR
                        case "D":
                            restrictedAreaPolyline.type = .restrictedAreaD
                        case "G":
                            restrictedAreaPolyline.type = .restrictedAreaG
                        case "Q":
                            restrictedAreaPolyline.type = .restrictedAreaQ
                        case "R":
                            restrictedAreaPolyline.type = .restrictedAreaR
                        case "RMZ":
                            restrictedAreaPolyline.type = .restrictedAreaRMZ
                        case "TMZ":
                            restrictedAreaPolyline.type = .restrictedAreaTMZ
                        case "W":
                            restrictedAreaPolyline.type = .restrictedAreaW
                        default:
                            restrictedAreaPolyline.type = .directLine
                        }
                    }
                
                }
            }
        }
    }
}
