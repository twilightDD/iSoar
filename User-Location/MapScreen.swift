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
import CoreMotion

//MARK: MapScreen
class MapScreen: UIViewController, MKMapViewDelegate {
    
     static let shared = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapScreenIdentifier") as! MapScreen
   
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var courseShort: UITextField!
    @IBOutlet weak var destinationAltitudeShort: UITextField!
    @IBOutlet weak var distanceShort: UITextField!
    @IBOutlet weak var destinationAirport: UITextField!
    @IBOutlet weak var altitudeShort: UITextField!
    @IBOutlet weak var speedkmhShort: UITextField!
    @IBOutlet weak var userTrackingModeButton: UISwitch!
    @IBOutlet weak var relativeAltitude: UILabel!
    @IBOutlet weak var pressure: UILabel!
    
    // MARK: properties
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    var userTrackingMode = true
    let altimeter = CMAltimeter()
    
    var selectedDestinationAirport:MapObjects.Airport?

    
    // ToDo Hardcoded Destination Airport Location
   
    var currentDirectionLine:DLPolyline?
    
    // MARK: - Init & Co.

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
        setupGestureRecognizers()
        mapView.delegate = self
        
        loadMapAnnotations()
       
        setupBarograph()
    }
    
    // MARK: Setup functions
    // Setup Location Manager
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    func setupGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        panGestureRecognizer.delegate = self
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(panGestureRecognizer)
    }

    // Center view on User Location on Map
    func centerViewOnUserLocation() {
        let defaults = UserDefaults.standard
        let mapRegionInMeters = defaults.value(forKey: SettingsViewController.Settings.mapRegionInMeters) as! Double
        if let coordinate = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: coordinate,
                                                 latitudinalMeters: mapRegionInMeters,
                                                 longitudinalMeters: mapRegionInMeters)
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
        let destinationAirports = MapObjects.shared.destinationAirports
        for destinationAirport in destinationAirports {
            let airportPointAnnotation = DLPointAnnotiation()
            
            airportPointAnnotation.title = destinationAirport.icao
            airportPointAnnotation.subtitle = destinationAirport.elevation.description
            airportPointAnnotation.coordinate = CLLocationCoordinate2D(latitude: destinationAirport.latitude,
                                                                       longitude: destinationAirport.longitude)
            airportPointAnnotation.imageName = "runway_grass"
            
            self.mapView.addAnnotation(airportPointAnnotation)
        }
        
        // TODO: RestrictedAreas aus MapObjects.shared herausnehmen und ähnlich wie AirPorts anzeigen lassen
        
      /*
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
                    
                    // Polyline erzeugen
                    let restrictedAreaPolyline = DLPolyline(coordinates: locationCoordinates,
                                                            count: locationCoordinates.count)
                    
                    // restricted area type
                    if let typeString = restrictedArea["type"] as? String {
                        switch typeString {
                            case "C":
                                restrictedAreaPolyline.type = .restrictedAreaC
                            case "CTR":
                                restrictedAreaPolyline.type = .restrictedAreaCTR
                            case "D":
                                restrictedAreaPolyline.type = .restrictedAreaD
                            case "G":
                                restrictedAreaPolyline.type = .restrictedAreaG
                            case "Q":
                                restrictedAreaPolyline.type = .restrictedAreaQ
                            case "R":
                                restrictedAreaPolyline.type = .restrictedAreaR
                            case "RMZ":
                                restrictedAreaPolyline.type = .restrictedAreaRMZ
                            case "TMZ":
                                restrictedAreaPolyline.type = .restrictedAreaTMZ
                            case "W":
                                restrictedAreaPolyline.type = .restrictedAreaW
                            default:
                                restrictedAreaPolyline.type = .directLine
                        }
                    }
                    
                    self.mapView.addOverlay(restrictedAreaPolyline)
                }
            }
        }
 */
    }
    
    
    func setupBarograph() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (data, error) in
                self.relativeAltitude.text = String.init(format: "%.1fM", (data?.relativeAltitude.floatValue)!)
                self.pressure.text = String.init(format: "%.2f hPA", (data?.pressure.floatValue)!*10)
            }
        }
    }
    
    

    // MARK: Handle GestureRecognizer
    @objc func screenEdgeSwiped(recognizer: UIScreenEdgePanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            mapView.userTrackingMode = .none
            userTrackingModeButton.isOn = false
        default:
            return
        }
    }
    

    @IBAction func toggleUserTrackingModeAction(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            centerViewOnUserLocation()
            mapView.userTrackingMode = .follow
        // mapView.camera.heading = 0
        case false:
            mapView.userTrackingMode = .none
        }
    }
}

// MARK: - MapScreen: CLLocationManagerDelegate
extension MapScreen: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        
        // Show Glider Image on Map
        if let image = UIImage(named: "glider") {
            let rotatedImage = image.rotate(course: currentLocation.course )
            
            if let currentLocationImage = mapView.view(for: mapView.userLocation) {
                currentLocationImage.image = rotatedImage
            }
        }
        
        // Current Location depending stuff
        // altitude
        let altitudeShort = String(format: "%.0fm", currentLocation.altitude)
        self.altitudeShort.text = altitudeShort
        // speed
        let speedkmhShort = String(format: "%.0fKmh", currentLocation.speed * 3.6)   //ToDo convert with Measurement
        self.speedkmhShort.text = "\(speedkmhShort)"
        // Steering Course
        let courseShort = String(format: "%.0f°", currentLocation.course)
        self.courseShort.text = courseShort
        
        
        
        // Destination depending stuff
        if let selectedDestinationAirport = MapScreen.shared.selectedDestinationAirport  {
            // ICAO
            self.destinationAirport.text = selectedDestinationAirport.icao
            
            // Distance
            let destinationAirportLocation = CLLocation(latitude: selectedDestinationAirport.latitude,
                                                        longitude: selectedDestinationAirport.longitude)
            let distance = currentLocation.distance(from: destinationAirportLocation) // result is in meters
            let distanceShort = String(format: "%.0fKm", distance/1000)
            self.distanceShort.text = distanceShort
        
            
            let defaults = UserDefaults.standard
            
            // Calculate Glider Sink Rate to Destination
            let safetyAltitude = defaults.value(forKey: SettingsViewController.Settings.safetyAltitude) as! Double
            let gliderRatio = defaults.value(forKey: SettingsViewController.Settings.gliderRatio) as! Double
            
            let gliderRatioMeter = gliderRatio * 1000       //Gleitzahl in Meter
            let gliderSinkRatePerMeter = 1000 / gliderRatioMeter    //Sinkrate pro Meter
            let gliderSinkRateToDestination = distance * gliderSinkRatePerMeter   //Sinkrate to Destination in Meter
        
            // Calculate altitude of Glider at Destination
            let destinationAltitude = currentLocation.altitude - selectedDestinationAirport.elevation - safetyAltitude - gliderSinkRateToDestination
            let destinationAltitudeShort = String(format:"%.0fm", destinationAltitude)
            self.destinationAltitudeShort.text = destinationAltitudeShort
            
            //Add MKPolyLine as an overlay - reflects the direct line between current location and destinationAirport.
            if self.currentDirectionLine != nil {
                self.mapView.removeOverlay(self.currentDirectionLine!)
            }
            let destinationAirportLocationCoordinate = CLLocationCoordinate2D(latitude: selectedDestinationAirport.latitude,
                                                                              longitude: selectedDestinationAirport.longitude)
            let newDirectionCoordinates:[CLLocationCoordinate2D] = [currentLocation.coordinate, destinationAirportLocationCoordinate]
            self.currentDirectionLine = DLPolyline(coordinates: newDirectionCoordinates,
                                                   count: newDirectionCoordinates.count)
            self.currentDirectionLine?.type = .directLine
            
            self.mapView.addOverlay(self.currentDirectionLine!)
        }        
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
                case .directLine:
                    overlayRenderer.strokeColor = .blue
                    overlayRenderer.lineWidth = 1.0
                case .restrictedAreaR:
                    overlayRenderer.strokeColor = .red
                    overlayRenderer.lineWidth = 1.5
                case .restrictedAreaRMZ:
                    overlayRenderer.strokeColor = .purple
                    overlayRenderer.lineWidth = 1.0
                default: // All other (just in case)
                    overlayRenderer.strokeColor = .black
                    overlayRenderer.lineWidth = 1.0
            }
        }
            
        return overlayRenderer
    }
}

// MARK: - MapScreen:UIGestureRecognizerDelegate
extension MapScreen:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: UIimage Rotate Extension
extension UIImage {
    func rotate(course: Double) -> UIImage? {
        let radians = course * Double.pi / 180
        return self.rotate(radians: radians)
    }
    
    func rotate(radians: Double) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

// MARK: - DLPointAnnotiation
class DLPointAnnotiation: MKPointAnnotation {
    var imageName:String = ""
}

// MARK: - DLPolyline
class DLPolyline: MKPolyline {
    public enum DLPolylineType {
        case directLine
        case restrictedAreaC
        case restrictedAreaCTR
        case restrictedAreaD
        case restrictedAreaG
        case restrictedAreaQ
        case restrictedAreaR
        case restrictedAreaRMZ
        case restrictedAreaTMZ
        case restrictedAreaW
    }

    var type:DLPolylineType = .directLine // Default
    
}

