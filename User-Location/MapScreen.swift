//
//  MapScreen.swift
//  User-Location
//
//  Created by Denis Leupold on 8/24/18.
//  Copyright © 2018 Denis Leupold. All rights reserved.
//

// Disable automatic center
// Check if Charger is plugged in
// Button center Location
// App Icon
// Button Switch MapView

import UIKit
import MapKit
import CoreLocation


class MapScreen: UIViewController {
    
    
    struct Airport {
        var icao: String
        var city: String
        var latitude: Double
        var longitude: Double
        var altitude: Double
        var radioFrequency: Double
        var runways: String
    }

        

    
    @IBOutlet weak var mapView: MKMapView!

    
    @IBOutlet weak var speedkmhShort: UILabel!
    
    
    
    
    
    
    @IBOutlet weak var altitudeShort: UILabel!
    @IBOutlet weak var courseShort: UILabel!
    @IBOutlet weak var destinationAltitudeShort: UILabel!
    
    
    @IBOutlet weak var destinationAirport: UILabel!
    
    
    
    
    @IBOutlet weak var airportPicker: UIPickerView!
    
    
    
    
    
    var airports = [Airport]()
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAirport()
        checkLocationServices()
        

    }
    
    

    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("Didn't request permission for User Notifications")
        }
    }


    func setupAirport(){
        let stahringen = Airport(icao: "EDSR",
                                 city: "Stahringen",
                                 latitude: 47.801791,
                                 longitude: 8.978528,
                                 altitude: 419,
                                 radioFrequency: 127.530,
                                 runways: "01/19")

        let friedrichshafen = Airport(icao: "EDNY",
                                city: "Friedrichshafen",
                                latitude: 47.801791,
                                longitude: 8.978528,
                                altitude: 478,
                                radioFrequency: 125.123,
                                runways: "01/19")
        
        let leibertingen = Airport(icao: "EDNY",
                                      city: "Leibertingen",
                                      latitude: 47.801791,
                                      longitude: 8.978528,
                                      altitude: 612,
                                      radioFrequency: 125.123,
                                      runways: "01/19")
        
        self.airports = [stahringen,friedrichshafen, leibertingen]
    }
    
    
    
}

extension MapScreen: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    
        let altitude = location.altitude
        let altitudeShort = String(format: "%.0fm", altitude)
        self.altitudeShort.text = altitudeShort

        let speed = location.speed              // meter per second
        let speedkmhShort = String(format: "%.0f Kmh", speed*3.6)
        self.speedkmhShort.text = "\(speedkmhShort)"
        
        print (speedkmhShort)
        
        let course = location.course
        let courseShort = String(format: "%.0f°", course)
        self.courseShort.text = courseShort
        
        let safetyHeight: Double = 200                  //Sicherheitshöhe
        let airportAltitude: Double = 419             //Höhe EDSR

        let destinationAltitude = altitude-airportAltitude-safetyHeight
        let destinationAltitudeShort = String(format: "%.0fm", destinationAltitude)
        self.destinationAltitudeShort.text = destinationAltitudeShort
        
        let destinationAirport: String = "EDSR"
        self.destinationAirport.text = destinationAirport
    }
    

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
