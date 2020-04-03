//
//  LocationManager.swift
//  Glider Tool
//
//  Created by Peter Hauke on 03.04.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation
import CoreLocation


// MARK: - Protocol - LocationManagerDelegate
protocol LocationManagerDelegate: AnyObject {

    func locationManager(didUpdateLocations locations: [CLLocation])

}


// MARK: -
// MARK: - LocationManager
class LocationManager: NSObject {

    // MARK: Lets and Vars
    static private let shared = LocationManager()

    //Private
    private let locationManager = CLLocationManager()

    private(set) var currentLocation: CLLocation?
    private(set) var currentDistance: CLLocationDistance?

    private weak var delegate: LocationManagerDelegate?


    // MARK: - Public Class Methods
    class func registerForLocationUpdates(_ delegate: LocationManagerDelegate) {
        shared.delegate = delegate
        shared.checkLocationServices()
    }

    class func unRegisterForLocationUpdates() {
        shared.delegate = nil
        shared.locationManager.stopUpdatingLocation()
    }

}


// MARK: - Extension - Private Instance Methods
extension LocationManager {

    // Check for Location Services
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
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
                // Show alert instructing them how to turn on permissions
                break
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
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true
    }

}


// MARK: - LocationManager - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let delegate = self.delegate
            else { return }

        delegate.locationManager(didUpdateLocations: locations)
        
    }


    // Check for Location Authorization
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }

}
