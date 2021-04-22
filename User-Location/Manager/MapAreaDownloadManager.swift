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
    private static let shared = MapAreaDownloadManager()

    private var percentageDonloaded: Float = 0
    private var completedResourceParts: UInt64 = 0
    private var expectedResourceParts: UInt64 = 0

    // MARK: - Public Class Methods

    class func percentageDonloaded()
        -> Float {
            let percentageDonloaded: Float = shared.percentageDonloaded
            return percentageDonloaded

    }

    class func mapAreaDownloadIsCompleted() -> Bool {
        if shared.completedResourceParts == shared.expectedResourceParts,
            shared.expectedResourceParts != 0 {

            return true

        }

        return false

    }

    // MARK: - Init&Co.
    private init() {
        // Setup offline pack notification handlers.
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackProgressDidChange), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveError), name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveMaximumAllowedMapboxTiles), name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)

    }

    class func startOfflinePackDownload() {
        // Reset the Ressources Counts
        shared.completedResourceParts = 0
        shared.expectedResourceParts = 0

        shared.startOfflinePackDownload()

    }

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
        var context = Data()

        do {
            let archivedData = try NSKeyedArchiver.archivedData(withRootObject: userInfo, requiringSecureCoding: true)
            context = archivedData
        } catch {
            fatalError()
        }

        // Create and register an offline pack with the shared offline storage object.
        MGLOfflineStorage.shared.addPack(for: region, withContext: context) { (pack, error) in
            guard error == nil else {
                // The pack couldn’t be created for some reason.
                print("Error: \(error?.localizedDescription ?? "unknown error")")
                return
            }

            // Start downloading.
            pack?.resume()

        }

    }

    // MARK: - MGLOfflinePack Notification Handlers
    @objc func offlinePackProgressDidChange(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack {
            let progress = pack.progress

            completedResourceParts = progress.countOfResourcesCompleted
            expectedResourceParts = progress.countOfResourcesExpected

            // Calculate current progress percentage
            let progressPercentage = Float(completedResourceParts) / Float(expectedResourceParts)
            self.percentageDonloaded = progressPercentage

            if let userInfo = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSObject.self],
                                                                      from: pack.context) as? [String: String] {
                print("Offline pack “\(userInfo["name"] ?? "unknown")” has \(completedResourceParts) of \(expectedResourceParts) resources — \(String(format: "%.2f", progressPercentage * 100))%.")
            }
        }

    }

    @objc func offlinePackDidReceiveError(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSObject.self],
                                                                   from: pack.context) as? [String: String],
            let error = notification.userInfo?[MGLOfflinePackUserInfoKey.error] as? NSError {
            print("Map: \(UserDefaultsManager.selectedCountry()) for User: \(userInfo["name"] ?? "unknown")” received error: \(error.localizedFailureReason ?? "unknown error")")
        }

    }

    @objc func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSObject.self],
                                                                   from: pack.context) as? [String: String],
            let maximumCount = (notification.userInfo?[MGLOfflinePackUserInfoKey.maximumCount] as AnyObject).uint64Value {
            print("Map: \(UserDefaultsManager.selectedCountry()) for User: \(userInfo["name"] ?? "unknown")” reached limit of \(maximumCount) tiles.")
        }

    }

}
