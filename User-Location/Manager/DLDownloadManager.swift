//
//  DLDownloadManager.swift
//  Glider Tool
//
//  Created by sonic on 22.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

enum ContentType: String {
    case airports = "Airports.json"
    case glidermodels = "GliderModels.json"
}

class DLDownloadManager {
    
    // MARK: - Lets and Vars
    // Statics
    static private let shared = DLDownloadManager()
    
    // MARK: - Private Class Methods
    private class func urlFor(_ contentType: ContentType)
    -> URL {
        let urlString = Presets.DLDownloadManager.appSourceFilesURL + contentType.rawValue
        guard let url = URL(string: urlString)
        else { fatalError() }
        
        return url
    }
    
    // MARK: - Public Class Methods
    class func download(_ contentType: ContentType,
                        completion: @escaping (_ data: Data?) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let url = urlFor(contentType)
        let request = URLRequest(url: url,
                                 cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData)
        let dataTask = session.dataTask(with: request,
                                        completionHandler: { data, response, error in
                                            
                                            if let error = error {
                                                completion(nil)
                                                NotificationBanner.show(error.localizedDescription)
                                                return
                                            }
                                            
                                            if let response = response as? HTTPURLResponse {
                                                if response.statusCode == 200 {
                                                    completion(data)
                                                } else {
                                                    print("StatusCode NOT OK")
                                                    completion(nil)
                                                }
                                            } else {
                                                print("Response NOT OK")
                                                completion(nil)
                                            }
                                        }
        )
        dataTask.resume()
        
    }
    
}
