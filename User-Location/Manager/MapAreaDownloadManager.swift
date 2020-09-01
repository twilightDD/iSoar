//
//  MapAreaDownloadManager.swift
//  Glider Tool
//
//  Created by sonic on 31.08.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Mapbox

class MapAreaDownloadManager {
    
    // MARK: - Lets and Vars
    static let shared = MapAreaDownloadManager()
    
    var percentageDonloaded: Float = 0
    
    // MARK: - Init&Co.
    private init() {
        // Setup offline pack notification handlers.
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackProgressDidChange), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveError), name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveMaximumAllowedMapboxTiles), name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)
    }
    
    // MARK: - Public Class Methods
    
    class func test()
        -> Float {
            
                let abc = self.shared.percentageDonloaded

            return abc
    }
    
    
    func downloadButtonTapped() {
        startOfflinePackDownload()
    }
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func startOfflinePackDownload() {
        guard let userLocation = LocationManager.currentLocation() else { return }
        let userLocationCoordinate2D = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude),
                                                  longitude: (userLocation.coordinate.longitude))

        let southWest = CLLocationCoordinate2D(latitude: userLocationCoordinate2D.latitude-2,
                                        longitude: userLocationCoordinate2D.longitude-2)

        let northEast = CLLocationCoordinate2D(latitude: userLocationCoordinate2D.latitude+2,
                                        longitude: userLocationCoordinate2D.longitude+2)

        let bounds = MGLCoordinateBounds(sw: southWest, ne: northEast)
        
        // Exchange with UserDefaultsManager.styleURL()
        let region = MGLTilePyramidOfflineRegion(styleURL: URL(string: UserDefaultsManager.mapStyleURL()),
                                                 bounds: bounds,
                                                 fromZoomLevel: 1,
                                                 toZoomLevel: 13)
        
        // Store some data for identification purposes alongside the downloaded resources.
        let userInfo = ["name": "User View2"]
        let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
        
        // Create and register an offline pack with the shared offline storage object.
        MGLOfflineStorage.shared.addPack(for: region, withContext: context) { (pack, error) in
            guard error == nil else {
                // The pack couldn’t be created for some reason.
                print("Error: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            // Start downloading.
            pack!.resume()

        }
        
    }
    
    // MARK: - MGLOfflinePack notification handlers
    
    @objc func offlinePackProgressDidChange(notification: NSNotification) {
        // Get the offline pack this notification is regarding,
        // and the associated user info for the pack; in this case, `name = My Offline Pack`
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String] {
            let progress = pack.progress
            // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
            let completedResources = progress.countOfResourcesCompleted
            let expectedResources = progress.countOfResourcesExpected
            
            // Calculate current progress percentage.
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            self.percentageDonloaded = progressPercentage
            
            // If this pack has finished, print its size and resource count.
            if completedResources == expectedResources {
                let byteCount = ByteCountFormatter.string(fromByteCount: Int64(pack.progress.countOfBytesCompleted), countStyle: ByteCountFormatter.CountStyle.memory)
                print("Offline pack “\(userInfo["name"] ?? "unknown")” completed: \(byteCount), \(completedResources) resources")
                
                // Dismiss the AlertView of the Settings VC
                
            } else {
                // Otherwise, print download/verification progress.
                print("Offline pack “\(userInfo["name"] ?? "unknown")” has \(completedResources) of \(expectedResources) resources — \(String(format: "%.2f", progressPercentage * 100))%.")
                
                // Dismiss the AlertView of the Settings VC
                
            }
        }
    }
    
    @objc func offlinePackDidReceiveError(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let error = notification.userInfo?[MGLOfflinePackUserInfoKey.error] as? NSError {
            print("Offline pack “\(userInfo["name"] ?? "unknown")” received error: \(error.localizedFailureReason ?? "unknown error")")
        }
        
        // Dismiss the AlertView of the Settings VC
        
    }
    
    @objc func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let maximumCount = (notification.userInfo?[MGLOfflinePackUserInfoKey.maximumCount] as AnyObject).uint64Value {
            print("Offline pack “\(userInfo["name"] ?? "unknown")” reached limit of \(maximumCount) tiles.")
        }

        // Dismiss the AlertView of the Settings VC
        
    }

}
