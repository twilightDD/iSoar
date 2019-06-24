//
//  MapScreen.swift
//  Glider Tool
//
//  Created by Denis Leupold on 8/24/18.
//  Copyright © 2018 Denis Leupold. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion
import Mapbox

//MARK: MapScreen
class MapScreen: UIViewController, MKMapViewDelegate {
    
     static let shared = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapScreenIdentifier") as! MapScreen
   
    // MARK: IBOutlets
    @IBOutlet var mapView: MGLMapView!

    @IBOutlet weak var courseShort: UILabel!
    @IBOutlet weak var altitudeShort: UILabel!
    @IBOutlet weak var speedkmhShort: UILabel!
    
    //hidden
    @IBOutlet var relativeAltitude: UILabel!
    @IBOutlet var pressure: UILabel!
    @IBOutlet var destinationAltitudeShort: UITextField!
    @IBOutlet var distanceShort: UITextField!
    @IBOutlet var destinationAirport: UITextField!
    
    // MARK: properties
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    
    //let altimeter = CMAltimeter()
    
    var selectedDestinationAirport:MapObjects.Airport?
   
    var currentDirectionLine:DLPolyline?
    
    var userTrackingMode = true
    var userFollow = false
    
    // MARK: - Init & Co.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
        setupMapBox()
        setupCenterMapOnUserLocationButton()
        
        setupGestureRecognizers()
        //loadMapAnnotations()
        //setupBarometer()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Setup functions
    // Set up Location Manager
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    // Set up MapBox MapView
    func setupMapBox() {
        let url = URL(string: "mapbox://styles/dlmapbox/cjwrbxi3x10fv1ck92xfdgz66")
        self.mapView.styleURL = url
        
        mapView.tintColor = .red
        mapView.allowsRotating = false
        mapView.allowsTilting = false
        
        // MGLMapboxMetricsEnabledSettingShownInApp: YES - Info.plist
        // MGLMapboxMetricsEnabled = false
        // https://docs.mapbox.com/help/how-mapbox-works/mobile-apps/#telemetry
        mapView.logoView.isHidden = false
        mapView.attributionButton.isHidden = false
        mapView.attributionButton.tintColor = .lightGray
        
        // Center Map to Airport Stuttgart at App Start
        mapView.setCenter(CLLocationCoordinate2D(
            latitude: 48.686251,
            longitude: 9.205404),
                          zoomLevel: 9.5,
                          animated: true)
    }
    
    // Set up User tracking mode button.
    @IBAction func locationButtonTapped(sender: UserLocationButton) {
        self.userFollow = !self.userFollow
        sender.updateArrowForTrackingMode(state: self.userFollow)
        
        if self.userFollow == true {
            if let _ = self.currentLocation {
                self.mapView.setCenter(self.currentLocation!.coordinate, animated: true)
            }
        }
    }
    
    // Button creation and autolayout setup
    func setupCenterMapOnUserLocationButton() {
        let userLocationButton = UserLocationButton(buttonSize: 40)
        userLocationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        userLocationButton.tintColor = mapView.tintColor
        
        // Setup constraints such that the button is placed within
        // the upper left corner of the view.
        userLocationButton.translatesAutoresizingMaskIntoConstraints = false
        
        var leadingConstraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            leadingConstraint = NSLayoutConstraint(item: userLocationButton, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 10)
        } else {
            leadingConstraint = NSLayoutConstraint(item: userLocationButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 10)
        }
        
        let constraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: userLocationButton, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 50),
            leadingConstraint,
            NSLayoutConstraint(item: userLocationButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: userLocationButton.frame.size.height),
            NSLayoutConstraint(item: userLocationButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: userLocationButton.frame.size.width)
        ]
        
        view.addSubview(userLocationButton)
        view.addConstraints(constraints)
    }


// MARK: - Custom UIButton subclass
class UserLocationButton: UIButton {
    private var arrow: CAShapeLayer?
    private let buttonSize: CGFloat
    
    // Initializer to create the user tracking mode button
    init(buttonSize: CGFloat) {
        self.buttonSize = buttonSize
        super.init(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        self.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.layer.cornerRadius = 4
        
        let arrow = CAShapeLayer()
        arrow.path = arrowPath()
        arrow.lineWidth = 2
        arrow.lineJoin = CAShapeLayerLineJoin.round
        arrow.bounds = CGRect(x: 0, y: 0, width: buttonSize / 2, height: buttonSize / 2)
        arrow.position = CGPoint(x: buttonSize / 2, y: buttonSize / 2)
        arrow.shouldRasterize = true
        arrow.rasterizationScale = UIScreen.main.scale
        arrow.drawsAsynchronously = true
        
        self.arrow = arrow
        
        // Update arrow for initial tracking mode
        updateArrowForTrackingMode(mode: .none)
        layer.addSublayer(self.arrow!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Create a new bezier path to represent the tracking mode arrow,
    // making sure the arrow does not get drawn outside of the
    // frame size of the UIButton.
    private func arrowPath() -> CGPath {
        let bezierPath = UIBezierPath()
        let max: CGFloat = buttonSize / 2
        bezierPath.move(to: CGPoint(x: max * 0.5, y: 0))
        bezierPath.addLine(to: CGPoint(x: max * 0.1, y: max))
        bezierPath.addLine(to: CGPoint(x: max * 0.5, y: max * 0.65))
        bezierPath.addLine(to: CGPoint(x: max * 0.9, y: max))
        bezierPath.addLine(to: CGPoint(x: max * 0.5, y: 0))
        bezierPath.close()
        
        return bezierPath.cgPath
    }
    
    // Update the arrow's color and rotation when tracking mode is changed.
    func updateArrowForTrackingMode(state:Bool) {
        let activePrimaryColor = UIColor.red
        let disabledPrimaryColor = UIColor.clear
        let disabledSecondaryColor = UIColor.black
        let rotatedArrow = CGFloat(0.66)
        if state {
            updateArrow(fillColor: disabledPrimaryColor, strokeColor: activePrimaryColor, rotation: 0)
        }
        else {
            updateArrow(fillColor: disabledPrimaryColor, strokeColor: disabledSecondaryColor, rotation: 0)
        }
    }
    
    // Setup Update Arror for User Tracking Mode
    func updateArrowForTrackingMode(mode: MGLUserTrackingMode) {
        let activePrimaryColor = UIColor.red
        let disabledPrimaryColor = UIColor.clear
        let disabledSecondaryColor = UIColor.black
        let rotatedArrow = CGFloat(0.66)
        
        switch mode {
        case .none:
            updateArrow(fillColor: disabledPrimaryColor, strokeColor: disabledSecondaryColor, rotation: 0)
        case .follow:
            updateArrow(fillColor: disabledPrimaryColor, strokeColor: activePrimaryColor, rotation: 0)
        case .followWithHeading:
            updateArrow(fillColor: activePrimaryColor, strokeColor: activePrimaryColor, rotation: rotatedArrow)
        case .followWithCourse:
            updateArrow(fillColor: activePrimaryColor, strokeColor: activePrimaryColor, rotation: 0)
        @unknown default:
            fatalError("Unknown user tracking mode")
        }
    }
    
    // Update Map Center Arrow Colors
    func updateArrow(fillColor: UIColor, strokeColor: UIColor, rotation: CGFloat) {
        guard let arrow = arrow else { return }
        arrow.fillColor = fillColor.cgColor
        arrow.strokeColor = strokeColor.cgColor
        arrow.setAffineTransform(CGAffineTransform.identity.rotated(by: rotation))
        
        // Re-center the arrow within the button if rotated
        if rotation > 0 {
            arrow.position = CGPoint(x: buttonSize / 2 + 2, y: buttonSize / 2 - 2)
        }
        layoutIfNeeded()
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

    //Set up Gesture Recognizers
    func setupGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        panGestureRecognizer.delegate = self
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(panGestureRecognizer)
    }

    //ToDo: Das geht so nicht! Beim zweiten Swipe macht er das Tracking wieder an
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            self.userFollow = !self.userFollow
            print("Swipe recognized")
            // ToDo: Set Arrow Color
        }
    }
    
//    func loadMapAnnotations() {
//        let destinationAirports = MapObjects.shared.destinationAirports
//        for destinationAirport in destinationAirports {
//            let airportPointAnnotation = DLPointAnnotiation()
//
//            airportPointAnnotation.title = destinationAirport.icao
//            airportPointAnnotation.subtitle = destinationAirport.elevation.description
//            airportPointAnnotation.coordinate = CLLocationCoordinate2D(latitude: destinationAirport.latitude,
//                                                                       longitude: destinationAirport.longitude)
//            airportPointAnnotation.imageName = "runway_grass"
//
//            //self.mapView.addAnnotation(airportPointAnnotation)
//        }
    
    }
    
// Setup Barometer
//    func setupBarometer() {
//        if CMAltimeter.isRelativeAltitudeAvailable() {
//            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (data, error) in
//                self.relativeAltitude.text = String.init(format: "%.1fM", (data?.relativeAltitude.floatValue)!)
//                self.pressure.text = String.init(format: "%.2f hPA", (data?.pressure.floatValue)!*10)
//            }
//        }
//    }


// MARK: - MapScreen: CLLocationManagerDelegate
extension MapScreen: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        self.currentLocation = currentLocation
        
        // Show Glider Image on Map
        if let image = UIImage(named: "glider") {
            let rotatedImage = image.rotate(course: currentLocation.course )
            
//            if let currentLocationImage = mapView.view(for: mapView.userLocation) {
//                currentLocationImage.image = rotatedImage
//            }
        }
        
        // Get User Tracking State - If true - set Map center on User Location
        if self.userFollow == true {
            self.mapView.setCenter(currentLocation.coordinate, animated: true)
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
            
            // Calculate Glider Sink Rate to Destination Airport
            let gliderRatioMeter = gliderRatio * 1000       //Gleitzahl in Meter
            let gliderSinkRatePerMeter = 1000 / gliderRatioMeter    //Sinkrate pro Meter
            let gliderSinkRateToDestination = distance * gliderSinkRatePerMeter   //Sinkrate to Destination in Meter
        
            // Calculate altitude of Glider at Destination Airport
            let destinationAltitude = currentLocation.altitude - selectedDestinationAirport.elevation - safetyAltitude - gliderSinkRateToDestination
            let destinationAltitudeShort = String(format:"%.0fm", destinationAltitude)
            self.destinationAltitudeShort.text = destinationAltitudeShort
            
            // ToDo: Calculate Gliding-Range - Does not work without Surface Elevation
            // let glidingRange = (currentLocation.altitude - safetyAltitude)*gliderRatio
            
            //Add MKPolyLine as an overlay - reflects the direct line between current location and destinationAirport.
            if self.currentDirectionLine != nil {
               // self.mapView.removeOverlay(self.currentDirectionLine!)
            }
            let destinationAirportLocationCoordinate = CLLocationCoordinate2D(latitude: selectedDestinationAirport.latitude,
                                                                              longitude: selectedDestinationAirport.longitude)
            let newDirectionCoordinates:[CLLocationCoordinate2D] = [currentLocation.coordinate, destinationAirportLocationCoordinate]
            self.currentDirectionLine = DLPolyline(coordinates: newDirectionCoordinates,
                                                   count: newDirectionCoordinates.count)
            self.currentDirectionLine?.type = .directLine
            
            //self.mapView.addOverlay(self.currentDirectionLine!)
        }
    }
    
    // Show Annotation on Map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // Get annotationView
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            //ToDo: performSegue(withIdentifier: "AirportInfoSegue", sender: self)
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
    
    // ToDo: Open AirportInfoViewController by tapping Airport Annotation
    func mapView(MapView: MKMapView!, annotation: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotation.rightCalloutAccessoryView {
            performSegue(withIdentifier: "AirportInfoSegue", sender: self)
            print("Opening AirportInfoViewController")
        }
    }
    
    // Check for Location Authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    // Draw and renew Polyline Overlay on Map
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

// MARK: - UIimage Rotate Extension
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

