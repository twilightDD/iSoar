//
//  MapObjects.swift
//  Glider Tool
//
//  Created by Peter Hauke on 02.06.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation
import CoreLocation

//MARK: - MapObjects
class MapObjects{

    //MARK: - Lets and Vars
    static let shared = MapObjects()
    private var destinationAirports = [MapObjects.Airport]()
    
    private let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!

    //MARK: - Init&Co.
    private init(){
        checkForMapOjectsInDocumentsFolder()
        loadAirports()
    }

    //MARK: - Public Methods
    // updateDistance
    func updateDistance() {
        if let currentLocation = MapScreen.shared!.currentLocation {
            var puffer = [MapObjects.Airport]()
            for var destinationAirport in destinationAirports {

                let destinationAirportLocation = CLLocation(latitude: destinationAirport.latitude,
                                                            longitude: destinationAirport.longitude)

                let currentDistance = currentLocation.distance(from: destinationAirportLocation)
                destinationAirport.updateDistance(currentDistance)

                puffer.append(destinationAirport)
            }

            destinationAirports = puffer
        }
    }

    // sortedDestinationAirports
    func sortedDestinationAirports(by sortIndicator: SortIndicator)
        -> [MapObjects.Airport]? {

            switch sortIndicator {
            case .name:
                let result = destinationAirports.sorted(by: { ($0.name < $1.name) })
                return result
            case .distance:
                let result = destinationAirports.sorted(by: { ($0.distance! < $1.distance!) })
                return result
            }
    }
    

    // Download MapObjects.json from Server
    func downloadMapObjectsFromServer() {
        // Create destination URL
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent("MapObjects.json")

        // File Source URL
        let fileURL = URL(string: "https://www.leupold.me/MapObjects.json")

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)

        let request = URLRequest(url:fileURL!)

        let task = session.downloadTask(with: request) { [unowned self] (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                print("Downloading...")
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }

                do {
                    try FileManager.default.removeItem(at: destinationFileUrl)
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)

                    // Clear MapObjects.shared.destinationAirports
                    self.destinationAirports.removeAll()

                    // Create Destination Airport List from new MapObjects.json
                    self.loadAirports()

                } catch (let writeError) {
                    print("Error creating a file: \(destinationFileUrl) : \(writeError)")
                }

            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
            }
        }

        task.resume()
    }

    //MARK: - Private Methods
    // Check if MapOjects.json exists in Documents Folder
    private func checkForMapOjectsInDocumentsFolder() {
        // Check if MapObjects.json exists in Documents Folder
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)

        let mapObjectsInDocumentsFolder = documentsUrl.appendingPathComponent("MapObjects.json")
        let mapObjectsInBundle = URL(fileURLWithPath: Bundle.main.path(forResource: "MapObjects", ofType: "json")!)
        
        if let pathComponent = url.appendingPathComponent("MapObjects.json") {
            
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("MapObjects available in Documents Folder.")
            } else {
                print("MapObjects not found in Documents Folder. Copy...")
                do {
                try FileManager.default.copyItem(at: mapObjectsInBundle, to: mapObjectsInDocumentsFolder)
                print("MapObjects copied to Documents Folder.")
                } catch (let writeError) {
                    print("Error creating a file: \(mapObjectsInDocumentsFolder) : \(writeError)")
                }
            }
        }
    }

    // Request for Location
    func requestForLocation(){
        //Code Process
        print("Location granted")
    }

    // Load Airports from json
    private func loadAirports() {
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


//MARK: - Extentsion - Structs and Enums

extension MapObjects {

    enum SortIndicator:Int {
        case name       = 0
        case distance   = 1
    }


    struct Airport {
        //MARK: Lets and Vars
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

        //MARK: Init&Co.
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

        //MARK: Public Methods
        mutating func updateDistance(_ newDistance:CLLocationDistance) {
            distance = newDistance
        }
    }
}
