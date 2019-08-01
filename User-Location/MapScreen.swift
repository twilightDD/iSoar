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
class MapScreen: UIViewController {

    static var shared:MapScreen?
        
    // MARK: IBOutlets
    @IBOutlet var mapView: MGLMapView!
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var destinationAltitudeLabel: UILabel!
    @IBOutlet weak var destinationAirportLabel: UILabel!
    
    
    //hidden
    

    @IBOutlet var relativeAltitude: UILabel!
    @IBOutlet var pressure: UILabel!

    
    // MARK: properties
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    var currentDistance:CLLocationDistance?
    
    lazy var userLocationButton:UserLocationButton = createUserLocationButton()
    
    //let altimeter = CMAltimeter()
    
    var selectedDestinationAirport:MapObjects.Airport?
    
    var currentDirectionLine:DLPolyline?
    
    var userTrackingMode = true
    var userFollow = false
    
    var showAltitudeInMeters = true
    var altitudeInMeters:CLLocationDistance = 0
    
    var showSpeedInKMH = true
    var speedInKMH:CLLocationSpeed = 0
    
    var showDistanceInKM = true
    var DistanceInKM:CLLocationDistance = 0
    
    // MARK: - Init & Co.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        MapScreen.shared = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationServices()
        
        setupMapBox()
        
        setupGestureRecognizers()
        
        //loadMapAnnotations()
    
        //setupBarometer()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Setup functions
    // Set up Location Manager
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    // Set up MapBox MapView
    func setupMapBox() {
        let url = URL(string: "mapbox://styles/dlmapbox/cjwrbxi3x10fv1ck92xfdgz66")
        self.mapView.styleURL = url
        
        mapView.delegate = self
        
        mapView.tintColor = .red
        mapView.allowsRotating = false
        mapView.allowsTilting = false
        
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserHeadingIndicator = true
        
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
        userLocationButton.updateArrowForTrackingMode(state: userFollow)
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
    
    func createUserLocationButton()
        -> UserLocationButton {
            let userLocationButton = UserLocationButton(buttonSize: 40)
            userLocationButton.addTarget(self, action: #selector(self.locationButtonTapped), for: .touchUpInside)
            userLocationButton.tintColor = self.mapView.tintColor
            
            // Setup constraints such that the button is placed within
            // the upper left corner of the view.
            userLocationButton.translatesAutoresizingMaskIntoConstraints = false
            
            var leadingConstraint: NSLayoutConstraint
            if #available(iOS 11.0, *) {
                leadingConstraint = NSLayoutConstraint(item: userLocationButton,
                                                       attribute: .leading,
                                                       relatedBy: .equal,
                                                       toItem: self.view.safeAreaLayoutGuide,
                                                       attribute: .leading,
                                                       multiplier: 1,
                                                       constant: 10)
            } else {
                leadingConstraint = NSLayoutConstraint(item: userLocationButton,
                                                       attribute: .leading,
                                                       relatedBy: .equal,
                                                       toItem: self.view,
                                                       attribute: .leading,
                                                       multiplier: 1,
                                                       constant: 10)
            }
            
            let constraints: [NSLayoutConstraint] = [NSLayoutConstraint(item: userLocationButton,
                                                                        attribute: .top,
                                                                        relatedBy: .greaterThanOrEqual,
                                                                        toItem: topBar,
                                                                        attribute: .bottom,
                                                                        multiplier: 1,
                                                                        constant: 10),
                                                     leadingConstraint,
                                                     NSLayoutConstraint(item: userLocationButton,
                                                                        attribute: .height,
                                                                        relatedBy: .equal,
                                                                        toItem: nil,
                                                                        attribute: .notAnAttribute,
                                                                        multiplier: 1,
                                                                        constant: userLocationButton.frame.size.height),
                                                     NSLayoutConstraint(item: userLocationButton,
                                                                        attribute: .width,
                                                                        relatedBy: .equal,
                                                                        toItem: nil,
                                                                        attribute: .notAnAttribute,
                                                                        multiplier: 1,
                                                                        constant: userLocationButton.frame.size.width)]
            
            self.view.addSubview(userLocationButton)
            self.view.addConstraints(constraints)
            
            return userLocationButton
    }
    
    // MARK: - Gesture Recognizer Funcs
    //Set up Gesture Recognizers
    func setupGestureRecognizers() {
        // MapView
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        panGestureRecognizer.delegate = self
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(panGestureRecognizer)
        
        // Altitude Label
        let tapOnAltitudeLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnAltitudeLabel))
        altitudeLabel.addGestureRecognizer(tapOnAltitudeLabelRecognizer)
        altitudeLabel.isUserInteractionEnabled = true
        
        // Speed Label
        let tapOnSpeedLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnSpeedLabel))
        speedLabel.addGestureRecognizer(tapOnSpeedLabelRecognizer)
        speedLabel.isUserInteractionEnabled = true
        
        // Distance Label
        let tapOnDistanceLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnDistanceLabel))
        distanceLabel.addGestureRecognizer(tapOnDistanceLabelRecognizer)
        distanceLabel.isUserInteractionEnabled = true
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            if userFollow == true {
                self.userFollow = false
                userLocationButton.updateArrowForTrackingMode(state: self.userFollow)
            }
            print("Swipe recognized")
        }
    }
    
    @objc func tapOnAltitudeLabel(_ recognizer: UITapGestureRecognizer) {
        showAltitudeInMeters = !showAltitudeInMeters
        
        updateAltitudeLabel()
    }
    
    @objc func tapOnSpeedLabel(_ recognizer: UITapGestureRecognizer) {
        showSpeedInKMH = !showSpeedInKMH
    
        updateSpeedLabel()
    }
    
    @objc func tapOnDistanceLabel(_ recognizer: UITapGestureRecognizer) {
        showDistanceInKM = !showDistanceInKM
        
        updateDistanceLabel()
    }
    
    // MARK: - Action Funcs
    // Set up User tracking mode button.
    @IBAction func locationButtonTapped(sender: UserLocationButton) {
        self.userFollow = !self.userFollow
        userLocationButton.updateArrowForTrackingMode(state: self.userFollow)
        
        if self.userFollow == true {
            if let _ = self.currentLocation {
                self.mapView.setCenter(self.currentLocation!.coordinate, animated: true)
            }
        }
    }
    
    //MARK: - Private Methods
    
    func loadMapAnnotations() {
        let destinationAirports = MapObjects.shared.destinationAirports
        for destinationAirport in destinationAirports {
            let airportPointAnnotation = DLPointAnnotiation()
            airportPointAnnotation.coordinate = CLLocationCoordinate2D(latitude: destinationAirport.latitude,
                                                                       longitude: destinationAirport.longitude)
            airportPointAnnotation.title = "title"
            airportPointAnnotation.imageName = "runway_grass"
            
            mapView.addAnnotation(airportPointAnnotation)
        }
    }
    
    func updateAltitudeLabel() {
        guard let currentLocation = currentLocation else {
            return
        }

        var altituteLabelText = ""
        if showAltitudeInMeters == true {
            altituteLabelText =  String(format: "%.0fm", currentLocation.altitude)
        }
        else {
            let altitudeInFeet = currentLocation.altitude * 3.28084
            altituteLabelText = String(format: "%.0fft", altitudeInFeet)
        }
        
        altitudeLabel.text = altituteLabelText
    }
    
    func updateSpeedLabel() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        var speedLabelText = ""
        if showSpeedInKMH == true {
            let speedInKMH = currentLocation.speed * 3.6
            speedLabelText =  String(format: "%.0fKmh", speedInKMH)
        }
        else {
            let speedInKT = currentLocation.speed * 1.852
            speedLabelText = String(format: "%.0fKt", speedInKT)
        }
        
        speedLabel.text = speedLabelText
    }

    func updateDistanceLabel() {
        guard let currentDistance = currentDistance else {
            return
        }

        var distanceLabelText = ""
        if showDistanceInKM == true {
        
            let distanceInKm = currentDistance/1000
            distanceLabelText =  String(format: "%.1fKm", distanceInKm)
        }
        else {
            let distcanceInMi = currentDistance/1000/1.852
            distanceLabelText = String(format: "%.1fNm", distcanceInMi)
        }

        distanceLabel.text = distanceLabelText
    }
    
    func updateDestinationAltitudeLabel() {
        guard let currentLocation = currentLocation else {
            return
        }
        guard let currentDistance = currentDistance else {
            return
        }
        guard  let selectedDestinationAirport = selectedDestinationAirport else {
            return
        }
        
        let defaults = UserDefaults.standard
        
        // Calculate Glider Sink Rate to Destination
        let safetyAltitude = defaults.value(forKey: SettingsViewController.Settings.safetyAltitude) as! Double
        let gliderRatio = defaults.value(forKey: SettingsViewController.Settings.gliderRatio) as! Double
        
        // Calculate Glider Sink Rate to Destination Airport
        let gliderRatioMeter = gliderRatio * 1000       //Gleitzahl in Meter
        let gliderSinkRatePerMeter = 1000 / gliderRatioMeter    //Sinkrate pro Meter
        let gliderSinkRateToDestination = currentDistance * gliderSinkRatePerMeter   //Sinkrate to Destination in Meter
        
        // Calculate altitude of Glider at Destination Airport
        let destinationAltitude = currentLocation.altitude - selectedDestinationAirport.elevation - safetyAltitude - gliderSinkRateToDestination
        let destinationAltitudeShort = String(format:"%.0fm", destinationAltitude)
        self.destinationAltitudeLabel.text = destinationAltitudeShort
    }
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

class DLCalloutView: UIView, MGLCalloutView {
    var representedObject: MGLAnnotation
    
    lazy var leftAccessoryView = UIView()
    lazy var rightAccessoryView = UIView()
    
    var delegate: MGLCalloutViewDelegate?
    
    required init(annotation: MGLAnnotation) {
        self.representedObject = annotation
        let rect = CGRect(x: 250, y: 250, width: 250, height: 250)
        super.init(frame: rect)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func presentCallout(from rect: CGRect, in view: UIView, constrainedTo constrainedRect: CGRect, animated: Bool) {
        view.addSubview(self)
    }
    
    func dismissCallout(animated: Bool) {
        if (animated){
            //do something cool
            removeFromSuperview()
        } else {
            removeFromSuperview()
        }
    }
}


// MARK: - MGLMapViewDelegate methods
extension MapScreen: MGLMapViewDelegate {
    
//    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
//        if let image = UIImage.init(named: "info") {
//            let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "airportIdentifer")
//            return annotationImage
//        }
//        return nil
//    }
    
    // https://stackoverflow.com/questions/26713582/didselectannotationview-not-called
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
        // Instantiate and return our custom callout view.
        let callOutView =  DLCalloutView(annotation: annotation)
        return callOutView
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        // Optionally handle taps on the callout.
        print("Tapped the callout for: \(annotation)")
        
        // Hide the callout.
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
    private func mapView(MapView: MGLMapView!, annotation: MGLAnnotationView, calloutAccessoryControlTapped control: UIControl) {

//https://stackoverflow.com/questions/51904284/how-do-you-create-a-custom-callout-for-mapbox-annotations
//        if control == annotation.rightCalloutAccessoryView {
//            performSegue(withIdentifier: "AirportInfoSegue", sender: self)
//            print("Opening AirportInfoViewController")
//        }
    }
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // Substitute our custom view for the user location annotation. This custom view is defined below.
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            return GliderUserLocationAnnotationView()
        }
        return nil
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        mapView.showsUserLocation = true
    }
    
    /*
    // TODO: WARUM wird das hier nicht aufgerufen?!
     func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        //print("\(annotation.self)")
        
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
            annotationView?.layer.borderWidth = 4.0
            annotationView?.layer.borderColor = UIColor.white.cgColor
            annotationView!.backgroundColor = UIColor(red: 0.03, green: 0.80, blue: 0.69, alpha: 1.0)
        }
        
        return annotationView
    }
 */
}



// MARK: - MapScreen: CLLocationManagerDelegate
extension MapScreen: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
       
        self.currentLocation = currentLocation
        
        // Get User Tracking State - If true - set Map center on User Location
        if self.userFollow == true {
            self.mapView.setCenter(currentLocation.coordinate, animated: true)
        }
        
        // Current Location depending stuff
        // Altitude
        updateAltitudeLabel()
        
        // Speed
        updateSpeedLabel()
        
        // Steering Course
        let courseShort = String(format: "%.0f°", currentLocation.course)
        self.courseLabel.text = courseShort
        
        // Destination depending stuff
        if let selectedDestinationAirport = MapScreen.shared!.selectedDestinationAirport  {
            // ICAO
            self.destinationAirportLabel.text = selectedDestinationAirport.icao
            
            // Distance
            let destinationAirportLocation = CLLocation(latitude: selectedDestinationAirport.latitude,
                                                        longitude: selectedDestinationAirport.longitude)
            currentDistance = currentLocation.distance(from: destinationAirportLocation) // result is in meters
            updateDistanceLabel()
            
            // DestinationAltitude
            updateDestinationAltitudeLabel()
            
            
            // ToDo: Calculate Gliding-Range - Does not work without Surface Elevation
            // let glidingRange = (currentLocation.altitude - safetyAltitude)*gliderRatio
            
            // Draw direct line between current location and destinationAirport.
            if self.currentDirectionLine != nil {
                 self.mapView.remove(self.currentDirectionLine!)
            }
            let destinationAirportLocationCoordinate = CLLocationCoordinate2D(latitude: selectedDestinationAirport.latitude,
                                                                              longitude: selectedDestinationAirport.longitude)
            let newDirectionCoordinates:[CLLocationCoordinate2D] = [currentLocation.coordinate, destinationAirportLocationCoordinate]
            self.currentDirectionLine = DLPolyline(coordinates: newDirectionCoordinates,
                                                   count: UInt(newDirectionCoordinates.count))
            self.currentDirectionLine?.type = .directLine
            
            self.mapView.add(self.currentDirectionLine!)
    
        }
    }
    
    // Show Annotation on Map
//    @nonobjc func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        // Get annotationView
//        let identifier = "Annotation"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            annotationView!.canShowCallout = true
//            //ToDo: performSegue(withIdentifier: "AirportInfoSegue", sender: self)
//        }
//
//        // Set image of annotationView depending of the type of annotation
//        if let castedAnnotation = annotation as? DLPointAnnotiation {
//            annotationView!.image = UIImage(named: castedAnnotation.imageName)
//        }
//        else if annotation === mapView.userLocation {
//            annotationView!.image = UIImage(named: "glider")
//        }
//        return annotationView
//    }
    
    // ToDo: Open AirportInfoViewController by tapping Airport Annotation
//    func mapView(MapView: MKMapView!, annotation: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//
//        if control == annotation.rightCalloutAccessoryView {
//            performSegue(withIdentifier: "AirportInfoSegue", sender: self)
//            print("Opening AirportInfoViewController")
//        }
//    }
    
    // Check for Location Authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    // Draw and renew Polyline Overlay on Map
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        var overlayRenderer = MKPolylineRenderer() // leeren MKOverlayRenderer anlegen
//        if let currentPolyline = overlay as? DLPolyline { // wenn overlay eine DLPolyline ist
//            overlayRenderer = MKPolylineRenderer(polyline: currentPolyline) // MKOverlayRenderer mit dem Pfad des Overlay versehen
//
//            // Abhängig vom type der DLPolyline setzen wir Farbe und Dicke
//            switch currentPolyline.type {
//            case .directLine:
//                overlayRenderer.strokeColor = .blue
//                overlayRenderer.lineWidth = 1.0
//            case .restrictedAreaR:
//                overlayRenderer.strokeColor = .red
//                overlayRenderer.lineWidth = 1.5
//            case .restrictedAreaRMZ:
//                overlayRenderer.strokeColor = .purple
//                overlayRenderer.lineWidth = 1.0
//            default: // All other (just in case)
//                overlayRenderer.strokeColor = .black
//                overlayRenderer.lineWidth = 1.0
//            }
//        }
//        return overlayRenderer
//    }
}

// MARK: - MapScreen:UIGestureRecognizerDelegate
extension MapScreen:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


// MARK: - DLPointAnnotiation
class DLPointAnnotiation: MGLPointAnnotation {
    
    var imageName:String = ""
    
}

// MARK: - DLPolyline
class DLPolyline: MGLPolyline {
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
