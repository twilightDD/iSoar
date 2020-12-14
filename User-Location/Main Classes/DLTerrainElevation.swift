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
    // Get Terrain elevation of current User Location via API from https://www.opentopodata.org
    class func currentTerrainElevation(latitude: Double, longitude: Double, completion: @escaping (_ elevation: Double?) -> Void) {
        
        guard let url = URL(string: "https://api.opentopodata.org/v1/srtm30m?locations=\(latitude),\(longitude)") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                // If successfully got the json from server - (statuscode: 200)
                if statusCode == 200 {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            
                            let results = json["results"] as! [[String: Any]]
                            for item in results {
                                
                                if let terrainElevation = item["elevation"] as? Double {
                                    completion(terrainElevation)
                                }
                                
                            }
                            
                        }
                        
                    } catch let error as NSError {
                        DLLogger.writeStringToLogFile("\(#function) - \(error.localizedDescription)")
                        //print("Failed to load: \(error.localizedDescription)")
                        completion(nil)
                    }
                    
                } else {
                    DLLogger.writeStringToLogFile("\(#function) - STATUSCODE NOT 200 / NOT OK")
                    //print("STATUSCODE NOT 200 / NOT OK")
                    completion(nil)
                }
                
            } else {
                DLLogger.writeStringToLogFile("\(#function) - got no Status Code")
                //print("NO STATUS CODE")
                completion(nil)
            }
            
        }
        
        task.resume()
        
    }
    
}
