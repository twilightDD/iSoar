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
    var completedResources: UInt64 = 0
    var expectedResources: UInt64 = 0
    
    // MARK: - Public Class Methods
    
    class func percentageDonloaded()
        -> Float? {
            let percentageDonloaded: Float = shared.percentageDonloaded
            return percentageDonloaded
    }
    
    class func completedResources()
        -> UInt64? {
            let completedResources: UInt64 = shared.completedResources
            return completedResources
    }
    
    class func expectedResources()
        -> UInt64? {
            let expectedResources: UInt64 = shared.expectedResources
            return expectedResources
    }
    
    // MARK: - Init&Co.
    private init() {
        // Setup offline pack notification handlers.
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackProgressDidChange), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveError), name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveMaximumAllowedMapboxTiles), name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)
    }
    
    
    func downloadButtonTapped() {
        
        // Reset the Ressources Counts
        self.completedResources = 0
        self.expectedResources = 0
        
        startOfflinePackDownload()
    }
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func startOfflinePackDownload() {
        guard let userLocation = LocationManager.currentLocation() else { return }
        let userLocationCoordinate2D = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude),
                                                              longitude: (userLocation.coordinate.longitude))
        
        let southWest = CLLocationCoordinate2D(latitude: userLocationCoordinate2D.latitude-1,
                                               longitude: userLocationCoordinate2D.longitude-1)
        
        let northEast = CLLocationCoordinate2D(latitude: userLocationCoordinate2D.latitude+1,
                                               longitude: userLocationCoordinate2D.longitude+1)
        
        let bounds = MGLCoordinateBounds(sw: southWest, ne: northEast)
        
        // Exchange with UserDefaultsManager.styleURL()
        let region = MGLTilePyramidOfflineRegion(styleURL: URL(string: UserDefaultsManager.mapStyleURL()),
                                                 bounds: bounds,
                                                 fromZoomLevel: 1,
                                                 toZoomLevel: 13)
        
        // Store some data for identification purposes alongside the downloaded resources.
        let userInfo = ["name": "John Doe"]
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
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSObject.self], from: pack.context) as? [String: String] {
            let progress = pack.progress
            
            self.completedResources = progress.countOfResourcesCompleted
            self.expectedResources = progress.countOfResourcesExpected
            
            // Calculate current progress percentage
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            self.percentageDonloaded = progressPercentage
            
            // If this pack has finished, print its size and resource count.
            if completedResources == expectedResources {
                print("Offline pack “\(userInfo["name"] ?? "unknown")” has \(completedResources) of \(expectedResources) resources — \(String(format: "%.2f", progressPercentage * 100))%.")
                
            } else {
                // Otherwise, print download/verification progress.
                print("Offline pack “\(userInfo["name"] ?? "unknown")” has \(completedResources) of \(expectedResources) resources — \(String(format: "%.2f", progressPercentage * 100))%.")
                
            }
        }
    }
    
    @objc func offlinePackDidReceiveError(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSObject.self], from: pack.context) as? [String: String],
            let error = notification.userInfo?[MGLOfflinePackUserInfoKey.error] as? NSError {
            print("Map: \(UserDefaultsManager.selectedCountry()) for User: \(userInfo["name"] ?? "unknown")” received error: \(error.localizedFailureReason ?? "unknown error")")
        }
        
    }
    
    @objc func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSObject.self], from: pack.context) as? [String: String],
            let maximumCount = (notification.userInfo?[MGLOfflinePackUserInfoKey.maximumCount] as AnyObject).uint64Value {
            print("Map: \(UserDefaultsManager.selectedCountry()) for User: \(userInfo["name"] ?? "unknown")” reached limit of \(maximumCount) tiles.")
        }
        
    }
    
}
