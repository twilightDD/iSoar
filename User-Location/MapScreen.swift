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
        var radioName: String
        var runways: String
    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var courseShort: UITextField!
    @IBOutlet weak var destinationAltitudeShort: UITextField!
    @IBOutlet weak var distanceShort: UITextField!
    @IBOutlet weak var destinationAirport: UITextField!
    @IBOutlet weak var altitudeShort: UITextField!
    @IBOutlet weak var speedkmhShort: UITextField!
    

    
    
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
    
    // Center view on User Location on Map
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
    
    // Check for Location Authorization
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
                                 latitude: 47.806103,
                                 longitude: 8.979535,
                                 altitude: 419,
                                 radioFrequency: 127.530,
                                 radioName: "Stahringen Info",
                                 runways: "01/19")

        let testfeld = Airport(icao: "TEST",
                                city: "Testfeld",
                                latitude: 47.801791,
                                longitude: 8.978528,
                                altitude: 478,
                                radioFrequency: 125.123,
                                radioName: "Acker Tower",
                                runways: "09/27")
        
        self.airports = [stahringen,testfeld]
    }
    
    
    
}

extension MapScreen: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        
        let airportAltitude: Double = 419             // Höhe EDSR

        // Measure Distance between own Location and Destination
        let ownLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let destinationAirportLocation = CLLocation(latitude: 47.806103, longitude: 8.979535)
        let distance = ownLocation.distance(from: destinationAirportLocation) // result is in meters
        let distanceShort = String(format: "%.0fKm", distance/1000)
        self.distanceShort.text = distanceShort
        
        let destinationAirport: String = "to EDSR"
        self.destinationAirport.text = destinationAirport
        
        
        let altitude = location.altitude
        //let altitude: Double = 2000
        let altitudeShort = String(format: "%.0fm", altitude)
        self.altitudeShort.text = altitudeShort

        let speed = location.speed                     // meter per second
        let speedkmhShort = String(format: "%.0fKmh", speed*3.6)   //ToDo convert with Measurement
        self.speedkmhShort.text = "\(speedkmhShort)"
        
        // Steering Course
        let course = location.course
        let courseShort = String(format: "%.0f°", course)
        self.courseShort.text = courseShort
        
        // Safety Height
        let safetyHeight: Double = 0
        
        // Calculate Glider Sink Rate to Destination
        let gliderRatio: Double = 30                  //Gleitzahl
        let gliderRatioMeter = gliderRatio*1000       //Gleitzahl in Meter
        let gliderSinkRatePerMeter = 1000/gliderRatioMeter    //Sinkrate pro Meter
        let gliderSinkRateToDestination = distance*gliderSinkRatePerMeter   //Sinkrate to Destination in Meter

        // Calculate Height of Glider at Destination
        let destinationAltitude = altitude-airportAltitude-safetyHeight-gliderSinkRateToDestination
        let destinationAltitudeShort = String(format: "%.0fm", destinationAltitude)
        self.destinationAltitudeShort.text = destinationAltitudeShort
        

        
        
        
        // Show Airports on Map
        let airport = MKPointAnnotation()
        airport.title = "EDSR"
        airport.coordinate = CLLocationCoordinate2D(latitude: 47.806103, longitude: 8.979535)
        self.mapView.addAnnotation(airport)
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is MKPointAnnotation else { return nil }
            
            let identifier = "Annotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
            } else {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        
   

// MARK: Output
        
//        // Output all Data
//        print("Latitude: \(location.coordinate.latitude)")
//        print("Longitude: \(location.coordinate.longitude)")
//        print("Altitude: \(altitudeShort)")
//        print("GliderRatio: \(gliderRatio)")
//        print("Glider Sink Rate per Meter \(gliderSinkRatePerMeter)")
//        print("Distance to Destination: \(distanceShort)")
//        print("Glider Sink Rate to Destination: \(gliderSinkRateToDestination)")
        
    }
    

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

