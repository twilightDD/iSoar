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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var courseShort: UITextField!
    @IBOutlet weak var destinationAltitudeShort: UITextField!
    @IBOutlet weak var distanceShort: UITextField!
    @IBOutlet weak var destinationAirport: UITextField!
    @IBOutlet weak var altitudeShort: UITextField!
    @IBOutlet weak var speedkmhShort: UITextField!
    
    let locationManager = CLLocationManager()
    
    // ToDo Hardcoded Destination Airport Location
    var destinationAirportCoords = CLLocationCoordinate2D(latitude: 47.806103, longitude: 8.979535)
    
    var currentDirectionLine:DLPolyline?
    
    // Temp Airport Direct to Buttons
    @IBAction func EDSRbutton(_ sender: Any) {
        destinationAirportCoords = CLLocationCoordinate2D(latitude: 47.806103, longitude: 8.979535)
    }
    @IBAction func LEIBbutton(_ sender: Any) {
        destinationAirportCoords = CLLocationCoordinate2D(latitude: 48.044272, longitude: 9.025188)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
        mapView.delegate = self
        
        loadMapAnnotations()
    }
    
    // Setup Location Manager
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    // Center view on User Location on Map
    func centerViewOnUserLocation() {
        let defaults = UserDefaults.standard
        let mapRegionInMeters = defaults.value(forKey: SettingsViewController.Settings.mapRegionInMeters) as! Double
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: mapRegionInMeters, longitudinalMeters: mapRegionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Check for Location Services
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

    func loadMapAnnotations() {
        // --- json laden
        
        // hier kommt der Inhalt der Datein rein
        var jsonAsString:String?
        
        // Dateipfad holen
        guard let mapObjectsPath = Bundle.main.path(forResource: "MapObjects",
                                                       ofType: "json")
            else { return }
        
        // aus Pfad eine URL machen
        let mapObjectsURL = URL(fileURLWithPath: mapObjectsPath)
        
        do {
            // URL laden und als String zurück geben
            try jsonAsString = String.init(contentsOf: mapObjectsURL)
        }
        catch {
            print("went wrong")
        }
        
        // String in Data konvertieren
        let jsonAsData = jsonAsString?.data(using: .utf8)
        
        // hier kommt der Inhalt der Datei als Dictionary rein
        var jsonAsDict = [String:NSArray]()
        do {
            // Umwandeln des Data in ein Dictionary (nennt sich deserialisieren)
            jsonAsDict = try JSONSerialization.jsonObject(with: jsonAsData!,
                                                          options: .allowFragments) as! [String : NSArray]
        }
        catch {
            print("json went wrong")
        }
        
        // --- Dict parsen und Annotations bauen
        // Airports
        // aus dem Dictionary den Zweig für 'Airports holen (sollte ein Array sein)
        if let airports:[NSDictionary] = jsonAsDict["Airports"] as? [NSDictionary] {
            // jedes Element des Arrays abklappern
            for airport in airports {
                let airportPointAnnotation = DLPointAnnotiation()
                
                airportPointAnnotation.title = airport["icao"] as? String
                
                let elevation = airport["elevation"] as? Double
                airportPointAnnotation.subtitle = elevation?.description
                
                airportPointAnnotation.coordinate = CLLocationCoordinate2D(latitude: (airport["latitude"] as? Double)!,
                                                                           longitude: (airport["longitude"] as? Double)!)
                
                airportPointAnnotation.imageName = "runway_grass"
                
                self.mapView.addAnnotation(airportPointAnnotation)
            }
        }
        
        // RestrictedAreas
        if let restrictedAreas:[NSDictionary] = jsonAsDict["RestrictedAreas"] as? [NSDictionary] {
            // jedes Element des Arrays abklappern
            for restrictedArea in restrictedAreas {
                // Coordinates rauskramen und in ein Array packen
                if let coordinatesFromDict:[NSDictionary] = restrictedArea["geoPoints"] as? [NSDictionary] {
                    var locationCoordinates:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
                    for coordinate in coordinatesFromDict {
                        guard let latitude = coordinate["latitude"] as? Double,
                            let longitude = coordinate["longitude"] as? Double
                            else { break }
                        locationCoordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    }
                    let restrictedAreaPolyline = DLPolyline(coordinates: locationCoordinates,
                                                            count: locationCoordinates.count)
                    restrictedAreaPolyline.type = .restrictedArea
                    self.mapView.addOverlay(restrictedAreaPolyline)
                }
            }
        }
    }
}

extension MapScreen: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let defaults = UserDefaults.standard
        
        // Show Glider Image on Map
        let currentLocationImage = mapView.view(for: mapView.userLocation)
        currentLocationImage?.image = UIImage(named: "glider")
        
        // Read Map Region from User Defaults
        let mapRegionInMeters = defaults.value(forKey: SettingsViewController.Settings.mapRegionInMeters) as! Double
        
        guard let currentLocation = locations.last else { return }
        
        let region = MKCoordinateRegion.init(center: currentLocation.coordinate, latitudinalMeters: mapRegionInMeters, longitudinalMeters: mapRegionInMeters)
        mapView.setRegion(region, animated: true)

        let destinationAirportLocation = CLLocation(latitude: self.destinationAirportCoords.latitude,
                                                    longitude: self.destinationAirportCoords.longitude)
        let distance = currentLocation.distance(from: destinationAirportLocation) // result is in meters
        let distanceShort = String(format: "%.0fKm", distance/1000)
        self.distanceShort.text = distanceShort
        
        // ToDo: Muss hier eigentlich nicht stehen, sondern nur, wenn anderer Zielhafen gewählt wird, wird String neu gestetzt
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
        let safetyAltitude = defaults.value(forKey: SettingsViewController.Settings.safetyAltitude) as! Double
        
        // Calculate Glider Sink Rate to Destination
        let gliderRatio = defaults.value(forKey: SettingsViewController.Settings.gliderRatio) as! Double
        let gliderRatioMeter = gliderRatio * 1000       //Gleitzahl in Meter
        let gliderSinkRatePerMeter = 1000 / gliderRatioMeter    //Sinkrate pro Meter
        let gliderSinkRateToDestination = distance * gliderSinkRatePerMeter   //Sinkrate to Destination in Meter

        // Calculate Height of Glider at Destination
        let destinationAirportElevation: Double = 419
        let destinationAltitude = altitude - destinationAirportElevation - safetyAltitude - gliderSinkRateToDestination
        let destinationAltitudeShort = String(format:"%.0fm", destinationAltitude)
        self.destinationAltitudeShort.text = destinationAltitudeShort
        
        //Add MKPolyLine as an overlay - reflects the direct line between current location and destinationAirport.
        if self.currentDirectionLine != nil {
            self.mapView.removeOverlay(self.currentDirectionLine!)
        }
        let newDirectionCoordinates:[CLLocationCoordinate2D] = [currentLocation.coordinate, destinationAirportCoords]
        self.currentDirectionLine = DLPolyline(coordinates: newDirectionCoordinates,
                                       count: newDirectionCoordinates.count)
        self.currentDirectionLine?.type = .directLine
        
        self.mapView.addOverlay(self.currentDirectionLine!)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Get annotationView
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        }
        
        // Set image of annotationView depending of the type of annotation
        if let castedAnnotation = annotation as? DLPointAnnotiation {
            annotationView!.image = UIImage(named: castedAnnotation.imageName)
        }
        else if annotation === mapView.userLocation {
            annotationView!.image = UIImage(named: "glider")
        }
        return annotationView
    }
    
    // Check for Location Authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    // Change Polyline Overlay on Map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var overlayRenderer = MKPolylineRenderer() // leeren MKOverlayRenderer anlegen
        if let currentPolyline = overlay as? DLPolyline { // wenn overlay eine DLPolyline ist
            overlayRenderer = MKPolylineRenderer(polyline: currentPolyline) // MKOverlayRenderer mit dem Pfad des Overlay versehen

            // Abhängig vom type der DLPolyline setzen wir Farbe und Dicke
            switch currentPolyline.type {
                case .directLine: // Direct Line
                    overlayRenderer.strokeColor = .blue
                    overlayRenderer.lineWidth = 1.0
                case .restrictedArea: // Restricted Area
                    overlayRenderer.strokeColor = .red
                    overlayRenderer.lineWidth = 1.0
                default: // All other (just in case)
                    overlayRenderer.strokeColor = .black
                    overlayRenderer.lineWidth = 1.0
            }
        }
            
        return overlayRenderer
    }
}

class DLPointAnnotiation: MKPointAnnotation {
    var imageName:String = ""
}

class DLPolyline: MKPolyline {
    enum DLPolylineType {
        case directLine
        case restrictedArea
        case areaOfInterest
    }

    var type:DLPolylineType = .directLine // Default
}

