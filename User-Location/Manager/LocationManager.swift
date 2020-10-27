//
//  LocationManager.swift
//  Glider Tool
//
//  Created by Peter Hauke on 03.04.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import CoreLocation
import UIKit

// MARK: - Protocol - LocationManagerDelegate
protocol LocationManagerDelegate: AnyObject {

    func locationManager(didUpdateLocations locations: [CLLocation])

}

// MARK: - LocationManager
class LocationManager: NSObject {

    // MARK: Lets and Vars
    // Statics
    static private let shared = LocationManager()

    // Public Class Vars
    class func currentLocation()
        -> CLLocation? {
            let currentLocation = shared.currentLocation
            return currentLocation
    }
    
    class func formerLocation()
        -> CLLocation? {
            let formerLocation = shared.formerLocation
            return formerLocation
    }

    // Private Lets and Vars
    private let locationManager = CLLocationManager()

    private var currentLocation: CLLocation?
    private var formerLocation: CLLocation?
    private var currentDistance: CLLocationDistance?

    private var delegates = NSHashTable<AnyObject>.weakObjects()

    // MARK: - Public Class Methods
    class func registerForLocationUpdates(_ delegate: LocationManagerDelegate) {
        // print("\(#function) - willAdd delegates.count = \(shared.delegates.count)")
        shared.delegates.add(delegate)
        // print("\(#function) - did Add delegates.count = \(shared.delegates.count)")
        shared.checkLocationServices()
    }

    class func unRegisterForLocationUpdates(_ delegate: LocationManagerDelegate) {
        // print("\(#function) - willRemove delegates.count = \(shared.delegates.count)")
        shared.delegates.remove(delegate)
        // print("\(#function) - did Remove delegates.count = \(shared.delegates.count)")

        if shared.delegates.count < 1 {
            // print("\(#function) - will stopUpdatingLocation")
            shared.locationManager.stopUpdatingLocation()
        }
    }

    /**
     Returns nil, if currentLocation is nil.
     */
    class func distanceFromCurrentLocationTo(location: CLLocation)
        -> CLLocationDistance? {
            guard let currentLocation = LocationManager.currentLocation()
                else { return nil }

            let newCurrentDistance = currentLocation.distance(from: location) // result is in meters
            return newCurrentDistance
    }

    class func altitudeDifferenceFromCurrentLocationTo(altitude: CLLocationDistance)
        -> CLLocationDistance? {
            guard let currentLocation = LocationManager.currentLocation()
                else { return nil }

            let altitudeDifference = currentLocation.altitude - altitude
            return altitudeDifference
    }
    
    // MARK: - Private Methods
    private func showLocationServiceDeniedAlert() {
        DLAlertViewController.showAlertViewController(title: Presets.LocationManager.locationServiceDeniedTitle,
                                                      message: Presets.LocationManager.locationServiceDeniedMessage,
                                                      preferredStyle: .alert,
                                                      addActionButton: true,
                                                      actionButtonTitle: "Settings",
                                                      actionButtonHandler: { action in
                                                        
                                                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                                            return
                                                        }
                                                        
                                                        if UIApplication.shared.canOpenURL(settingsUrl) {
                                                            UIApplication.shared.open(settingsUrl,
                                                                                      completionHandler: { success in
                                                                                        // Settings opened
                                                                                      })
                                                        }
                                                      },
                                                      
                                                      addCancelButton: true,
                                                      cancelButtonTitle: "Cancel")
        
    }

}

// MARK: - Extension - Private Instance Methods
extension LocationManager {

    // Check for Location Services
    private func checkLocationServices() {

        let locationServicesEnabled = CLLocationManager.locationServicesEnabled()
        if locationServicesEnabled == true {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }

    // Check for Location Authorization
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied:
            showLocationServiceDeniedAlert()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            print("Didn't request permission for User Notifications")
        }
    }

    // Set up Location Manager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
    }

}

// MARK: - LocationManager - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {

        guard let currentLocation = locations.last
            else { return }

        self.currentLocation = currentLocation

        // Inform delegate
        for delegate in delegates.allObjects {
            if let locationManagerDelegate = delegate as? LocationManagerDelegate {
                locationManagerDelegate.locationManager(didUpdateLocations: locations)
            }
        }
        
        formerLocation = currentLocation
        
    }
    
    // If LocationManager did Fail With Error
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        #if DEBUG
        if let coreLocationError = error as? CLError {
            switch coreLocationError {
            case CLError.locationUnknown:
                NotificationBanner.show("Location unknown")
            case CLError.headingFailure:
                NotificationBanner.show("Heading unknown")
            case CLError.denied:
                NotificationBanner.show("Location Error: User denied use of Location Services")
            default:
                NotificationBanner.show("Other Location error")
            }
        } else {
            NotificationBanner.show("Location Error: \(error.localizedDescription)")
        }
        #else
        
        #endif
        
    }
    
    // Check for Location Authorization
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }

}
