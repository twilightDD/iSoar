//
//  DLTerrainElevation.swift
//  Glider Tool
//
//  Created by sonic on 30.10.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

class DLTerrainElevation {
    
    // MARK: - Lets and Vars
    // Statics
    static private let shared = DLTerrainElevation()
    
    // MARK: - Public Class Methods
    static func currentTerrainElevation(completion: @escaping (_ elevation: Double?) -> Void) {
        
        let shared = DLTerrainElevation.shared
        
        let latitude = LocationManager.currentLocation()?.coordinate.latitude
        let longitude = LocationManager.currentLocation()?.coordinate.longitude
        
        let url = URL(string: "https://api.opentopodata.org/v1/srtm30m?locations=47,8")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                // If successfully got the json from server - (statuscode: 200)
                if statusCode == 200 {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            
                            let results = json["results"] as! [[String: Any]]
                            for item in results {
                                
                                let terrainElevation = item["elevation"] as! Double
                                
                                //print(terrainElevation)

                                completion(terrainElevation)
                            }
                            
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                        
                    }
                    
                } else {
                    completion(nil)
                }
                
            }
            
        }
        
    }
    
}


//DLTerrainElevation.currentTerrainElevation { elevation in
//    print("elevation \(elevation ?? 0.0)")
//}
