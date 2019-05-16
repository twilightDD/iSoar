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


class MapScreen: UIViewController, MKMapViewDelegate {

    struct Airports {
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
    
    var airports = [Airports]()
    let locationManager = CLLocationManager()
    let mapRegionInMeters: Double = 15000
    
    let coords1 = CLLocationCoordinate2D(latitude: 47.806103, longitude: 8.979535)
    let destinationAirportCoords = CLLocationCoordinate2D(latitude: 47.806103, longitude: 8.979535)
    
    var currentDirectionLine:MKPolyline?
    var restrictedAirspaceLine:MKPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAirport()
        checkLocationServices()
        
        mapView.delegate = self
        
        // Show Airports on Map
        let airportPointAnnotation = MKPointAnnotation()
        airportPointAnnotation.title = "EDSR"
        airportPointAnnotation.subtitle = "419m"
        airportPointAnnotation.coordinate = CLLocationCoordinate2D(latitude: 47.806103, longitude: 8.979535)
        self.mapView.addAnnotation(airportPointAnnotation)
        
       // draw overlay for military outpost in Radeirgendwas
        let triangle:[CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude:47.840000, longitude:9.060000),
                                                 CLLocationCoordinate2D(latitude:47.840000, longitude:9.100000),
                                                CLLocationCoordinate2D(latitude:47.864483,
                                                    longitude:9.100000),
                                                 CLLocationCoordinate2D(latitude:47.864483,
                                                    longitude:9.060000),
                                                 CLLocationCoordinate2D(latitude:47.840000, longitude:9.060000),
        
                                                 ]
        
        self.restrictedAirspaceLine = MKPolyline(coordinates: triangle,
                                          count: triangle.count)
        
        self.mapView.addOverlay(self.restrictedAirspaceLine!)
  }
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    // Center view on User Location on Map
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: mapRegionInMeters, longitudinalMeters: mapRegionInMeters)
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
        let stahringen = Airports(icao: "EDSR",
                                 city: "Stahringen",
                                 latitude: 47.806103,
                                 longitude: 8.979535,
                                 altitude: 419,
                                 radioFrequency: 127.530,
                                 radioName: "Stahringen Info",
                                 runways: "01/19")

        let testfeld = Airports(icao: "TEST",
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
        guard let currentLocation = locations.last else { return }
        let region = MKCoordinateRegion.init(center: currentLocation.coordinate, latitudinalMeters: mapRegionInMeters, longitudinalMeters: mapRegionInMeters)
        mapView.setRegion(region, animated: true)

        let defaults = UserDefaults.standard
        
        let destinationAirportLocation = CLLocation(latitude: self.destinationAirportCoords.latitude,
                                                    longitude: self.destinationAirportCoords.longitude)
        let distance = currentLocation.distance(from: destinationAirportLocation) // result is in meters
        let distanceShort = String(format: "%.0fKm", distance/1000)
        self.distanceShort.text = distanceShort
        
        // Muss hier eigentlich nicht stehen, sondern nur, wenn anderer Zielhafen gewählt wird, wird String neu gestetzt
        let destinationAirport: String = "to EDSR"
        self.destinationAirport.text = destinationAirport
        
        let altitude = currentLocation.altitude
        //let altitude: Double = 2000
        let altitudeShort = String(format: "%.0fm", altitude)
        self.altitudeShort.text = altitudeShort

        let speed = currentLocation.speed                     // meter per second
        let speedkmhShort = String(format: "%.0fKmh", speed*3.6)   //ToDo convert with Measurement
        self.speedkmhShort.text = "\(speedkmhShort)"
        
        // Steering Course
        let course = currentLocation.course
        let courseShort = String(format: "%.0f°", course)
        self.courseShort.text = courseShort
        
        // Safety Altitude
        let safetyAltitude = defaults.value(forKey: UserSettingsViewController.Settings.safetyAltitude) as! Double
        
        
        // Calculate Glider Sink Rate to Destination
        //let gliderRatio = defaults.value(forKey: UserSettingsViewController.Settings.gliderRatio) as! Double
        
        let gliderRatio: Double = 30                  //Gleitzahl
        let gliderRatioMeter = gliderRatio * 1000       //Gleitzahl in Meter
        let gliderSinkRatePerMeter = 1000 / gliderRatioMeter    //Sinkrate pro Meter
        let gliderSinkRateToDestination = distance * gliderSinkRatePerMeter   //Sinkrate to Destination in Meter

        // Calculate Height of Glider at Destination
        let airportAltitude: Double = 419             // Höhe EDSR
        let destinationAltitude = altitude - airportAltitude - safetyAltitude - gliderSinkRateToDestination
        let destinationAltitudeShort = String(format:"%.0fm", destinationAltitude)
        self.destinationAltitudeShort.text = destinationAltitudeShort
        
        //Add MKPolyLine as an overlay - reflects the direct line between current location and destinationAirport.
        if self.currentDirectionLine != nil {
            self.mapView.removeOverlay(self.currentDirectionLine!)
        }
        let newDirectionCoordinates:[CLLocationCoordinate2D] = [currentLocation.coordinate, destinationAirportCoords]
        self.currentDirectionLine = MKPolyline(coordinates: newDirectionCoordinates,
                                       count: newDirectionCoordinates.count)
        
        self.mapView.addOverlay(self.currentDirectionLine!)

        
        
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

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard annotation is MKPointAnnotation else {
            // zoom to hoome of dl
//            let region = MKCoordinateRegion.init(center: destinationAirportCoords,
//                        latitudinalMeters;: mapRegionInMeters,
//                        longitudinalMeters: mapRegionInMeters)
//            mapView.setRegion(region, animated: true)
            
            return nil
        }
        
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    // Change Direction Polyline Overlay to Map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Return an `MKPolylineRenderer` for the `MKPolyline` in the `MKMapViewDelegate`s method
        if let currentPolyline = overlay as? MKPolyline {
            let overlayRenderer = MKPolylineRenderer(polyline: currentPolyline)
            if currentPolyline == self.currentDirectionLine {
                overlayRenderer.strokeColor = .blue
                overlayRenderer.lineWidth = 1.0
            }
            else if currentPolyline == self.restrictedAirspaceLine {
                overlayRenderer.strokeColor = .purple
                overlayRenderer.lineWidth = 1.0
            }
            return overlayRenderer
        }
        
        fatalError("Something wrong...")
        //return MKOverlayRenderer()
    }
    
}

