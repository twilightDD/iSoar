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
    // Statics
    static private let shared = LocationManager()

    // Public Class Vars
    class func currentLocation()
        -> CLLocation? {
            let currentLocation = shared.currentLocation
            return currentLocation
    }

    class func currentDistance()
        -> CLLocationDistance? {
            let currentDistance = shared.currentDistance
            return currentDistance
    }

    //TODO: add destAirport to signature, 04042020, ph
    class func updateCurrentDistanceToDestinationAirport() {
        guard let selectedDestinationAirport = DestinationSelectionViewController.destinationAirport(),
            let currentLocation = LocationManager.currentLocation()
            else {
                shared.currentDistance = nil
                return
        }

        let destinationAirportLocation = CLLocation(latitude: selectedDestinationAirport.latitude,
                                                    longitude: selectedDestinationAirport.longitude)


        let newCurrentDistance = currentLocation.distance(from: destinationAirportLocation) // result is in meters
        shared.currentDistance = newCurrentDistance
    }


    // Private
    private let locationManager = CLLocationManager()

    private var currentLocation: CLLocation?
    private var currentDistance: CLLocationDistance?

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

        guard let currentLocation = locations.last
            else { return }

        self.currentLocation = currentLocation

        LocationManager.updateCurrentDistanceToDestinationAirport()

        // Inform delegate
        if let delegate = self.delegate {
            delegate.locationManager(didUpdateLocations: locations)
        }
        
    }


    // Check for Location Authorization
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }

}
