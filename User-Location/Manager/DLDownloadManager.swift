//
//  DLDownloadManager.swift
//  Glider Tool
//
//  Created by sonic on 22.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

// MARK: - Public Class Methods
enum ContentType: String {
    case airports = "Airports.json"
    case glidermodels = "GliderModels.json"
}

class DLDownloadManager {
    
    // MARK: - Lets and Vars
    // Statics
    static private let shared = DLDownloadManager()
    
    private class func urlFor(_ type: ContentType)
    -> URL {
        let urlString = "https://www.isoar.de/_b34/" + type.rawValue
        guard let url = URL(string: urlString)
        else { fatalError() }
        
        return url
    }
    
    class func download(_ type: ContentType,
                        completion: @escaping (_ data: Data) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let url = urlFor(type)
        let request = URLRequest(url: url)
        let dataTask = session.dataTask(with: request,
                                        completionHandler: { data, response, error in
                                            if error == nil {
                                                if let response = response as? HTTPURLResponse {
                                                    if response.statusCode == 200 {
                                                        if let data = data {
                                                            completion(data)
                                                        }
                                                    } else {
                                                        print("StatusCode NOT OK")
                                                    }
                                                } else {
                                                    print("Response NOT OK")
                                                }
                                            } else {
                                                print(error?.localizedDescription)
                                            }
                                        })
        dataTask.resume()
        
    }
    
}
