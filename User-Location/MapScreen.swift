//
//  MapScreen.swift
//  Glider Tool
//
//  Created by Denis Leupold on 8/24/18.
//  Copyright © 2018 Denis Leupold. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import Mapbox

//MARK: MapScreen
class MapScreen: UIViewController {
    
    static var shared:MapScreen?
    
    // MARK: IBOutlets
    @IBOutlet private var mapView: MGLMapView!
    @IBOutlet private weak var courseLabel: UILabel!
    @IBOutlet private weak var altitudeLabel: UILabel!
    @IBOutlet private weak var speedLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var destinationAltitudeLabel: UILabel!
    @IBOutlet private weak var destinationAirportLabel: UILabel!
    
    // MARK: Lets and Vars
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    var currentDistance:CLLocationDistance?
    let defaults = UserDefaults.standard
    
    lazy var userLocationButton:UserLocationButton = createUserLocationButton()
    
    //let altimeter = CMAltimeter()
    
    var selectedDestinationAirport:AirportDatabase.Airport? {
        didSet {
            updateDirectionLabelsAndLine()
        }
        
    }
    
    var currentDirectionLine:MGLPolyline?
    var currentFlightLine = MGLPolyline()
    
    var userTrackingMode = true
    var userFollow = false
    
    var showAltitudeInMeters = true
    var altitudeInMeters:CLLocationDistance = 0
    
    var showSpeedInKMH = true
    var speedInKMH:CLLocationSpeed = 0
    
    var showDistanceInKM = true
    var DistanceInKM:CLLocationDistance = 0
    
    var showTrackingRoute = false
        
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkTrackingRouteStatus()

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Setup functions
    // Set up Location Manager
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true
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
        
        mapView.resetNorth()
        
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
            locationManager.startUpdatingLocation()
            break
        @unknown default:
            print("Didn't request permission for User Notifications")
        }
    }
    
    // Create User Location Button
    func createUserLocationButton()
        -> UserLocationButton {
            let userLocationButton = UserLocationButton(buttonSize: 40)
            userLocationButton.addTarget(self, action: #selector(self.locationButtonTapped), for: .touchUpInside)
            userLocationButton.tintColor = self.mapView.tintColor
            
            // Setup constraints such that the button is placed within
            // the upper left corner of the view.
            userLocationButton.translatesAutoresizingMaskIntoConstraints = false
            
            userLocationButton.layer.borderWidth = 1
            userLocationButton.layer.borderColor = UIColor.red.cgColor
            // userLocationButton.layer.cornerRadius = 5
            
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
                                                                        toItem: courseLabel,
                                                                        attribute: .bottom,
                                                                        multiplier: 1,
                                                                        constant: 20),
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
    
    // MARK: - Gesture Recognizer Methods
    //Set up Gesture Recognizers
    private func setupGestureRecognizers() {
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
    // Update AltitudeLabel
    private func updateAltitudeLabel() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        var altituteLabelText = ""
        if showAltitudeInMeters == true {
            altituteLabelText =  String(format: "%.0f m", currentLocation.altitude)
        }
        else {
            let altitudeInFeet = currentLocation.altitude * 3.28084
            altituteLabelText = String(format: "%.0f ft", altitudeInFeet)
        }
        
        altitudeLabel.text = altituteLabelText
    }
    
    // Update SpeedLabel
    private func updateSpeedLabel() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        var speedLabelText = ""
        
        if currentLocation.speed < 0 {
            speedLabelText = "---"
        }
        else {
            if showSpeedInKMH == true {
                let speedInKMH = currentLocation.speed * 3.6
                speedLabelText =  String(format: "%.0f km/h", speedInKMH)
            }
            else {
                let speedInKT = currentLocation.speed * 1.852
                speedLabelText = String(format: "%.0f kt", speedInKT)
            }
        }
        speedLabel.text = speedLabelText
    }
    
    // Update DistanceLabel
    private func updateDistanceLabel() {
        guard let currentDistance = currentDistance else {
            return
        }
        
        var distanceLabelText = ""
        if showDistanceInKM == true {
            
            let distanceInKm = currentDistance/1000
            distanceLabelText =  String(format: "%.0f Km", distanceInKm)
        }
        else {
            let distcanceInMi = currentDistance/1000/1.852
            distanceLabelText = String(format: "%.0f NM", distcanceInMi)
        }
        
        distanceLabel.text = distanceLabelText
        
    }
    
    // Update DestinationAltitudeLabel
    private func updateDestinationAltitudeLabel() {
        guard let currentLocation = currentLocation else {
            return
        }
        guard let currentDistance = currentDistance else {
            return
        }
        guard  let selectedDestinationAirport = selectedDestinationAirport else {
            return
        }
        
        // Get User Default Values
        let defaults = UserDefaults.standard
        
        // Calculate Glider Sink Rate to Destination
        let safetyAltitude = defaults.value(forKey: SettingsViewController.Settings.SafetyAltitudeKey) as! Double
        let gliderRatio = defaults.value(forKey: SettingsViewController.Settings.GliderRatioKey) as! Double
        
        // Calculate Glider Sink Rate to Destination Airport
        let gliderRatioMeter = gliderRatio * 1000       //Gleitzahl in Meter
        let gliderSinkRatePerMeter = 1000 / gliderRatioMeter    //Sinkrate pro Meter
        let gliderSinkRateToDestination = currentDistance * gliderSinkRatePerMeter   //Sinkrate to Destination in Meter
        
        // Calculate altitude of Glider at Destination Airport
        let destinationAltitude = currentLocation.altitude - selectedDestinationAirport.elevation - safetyAltitude - gliderSinkRateToDestination
        let destinationAltitudeShort = String(format:"%.0f m", destinationAltitude)
        self.destinationAltitudeLabel.text = destinationAltitudeShort
        
        if destinationAltitude > 0 {
            destinationAltitudeLabel.textColor = UIColor(red: 150/255, green: 255/255, blue: 255/255, alpha: 1)
        }
        else {
            destinationAltitudeLabel.textColor = .red
        }
    }
    
    // Update Course Label
    private func updateCourseLabel() {
        guard let course = currentLocation?.course else {
            self.courseLabel.text = "---"
            return
        }
        
        if course < 0 {
            self.courseLabel.text = "---"
        }
        else {
            let courseShort = String(format: "%.0f°", course)
            self.courseLabel.text = courseShort
        }
    }
    
    // Update Direction Labels and Line
    private func updateDirectionLabelsAndLine() {
        // ICAO
        if let selectedDestinationAirport = selectedDestinationAirport {
            destinationAirportLabel.text = selectedDestinationAirport.icao
        }
        else {
            destinationAirportLabel.text = "---"
        }
        
        if let selectedDestinationAirport = selectedDestinationAirport,
            let currentLocation = currentLocation {
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
            
            
            let destinationAirportLocationCoordinate = CLLocationCoordinate2D(latitude: selectedDestinationAirport.latitude,
                                                                              longitude: selectedDestinationAirport.longitude)
            let newDirectionCoordinates:[CLLocationCoordinate2D] = [currentLocation.coordinate, destinationAirportLocationCoordinate]
            let newCurrentLine = MGLPolyline(coordinates: newDirectionCoordinates,
                                             count: UInt(newDirectionCoordinates.count))
            
            self.mapView.addAnnotation(newCurrentLine)
            
            // to avoid flickering we delay the removable of the "former" line a little bit; 16.12.19, ph
            if let currentDirectionLine = self.currentDirectionLine {
                let seconds = 0.025
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.mapView.removeAnnotation(currentDirectionLine)
                }
                
            }
            
            currentDirectionLine = newCurrentLine
        }
        else {
            distanceLabel.text = "---"
            destinationAltitudeLabel.text = "---"
            destinationAltitudeLabel.textColor = UIColor(red: 150/255, green: 255/255, blue: 255/255, alpha: 1)
            
            if let currentDirectionLine = currentDirectionLine {
                mapView.remove(currentDirectionLine)
                self.currentDirectionLine = nil
            }
        }
    }
    
    // MARK: Route Tracking
    // Check for Tracking Route Status ins Settings
    private func checkTrackingRouteStatus() {
        showTrackingRoute = defaults.value(forKey: SettingsViewController.Settings.ShowTrackingRouteSwitchKey) as! Bool
        if showTrackingRoute == true {
            // Delay Drawing and wait for Location
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.mapView.addAnnotation(self.currentFlightLine)
            }
        }
        else {
            mapView.removeAnnotation(currentFlightLine)
        }
    }
    
    // Draw Tracking Route Polyline on Map
    private func drawTrackingRoute() {
        if let currentLocation = self.currentLocation {
            var currentLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: currentLocation.coordinate.latitude,
                                                                          longitude: currentLocation.coordinate.longitude)
                currentFlightLine.appendCoordinates(&currentLocationCoordinate2D,
                                                    count: 1)
        }
        
    }
    
}

// ToDo: Documentation
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
    
    // Set the Direction Line color
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor.blue
    }
    
    // Set the Direction Line width
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 2.0
    }
    
    // Instantiate and return our custom callout view
    // https://stackoverflow.com/questions/26713582/didselectannotationview-not-called
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
        let callOutView =  DLCalloutView(annotation: annotation)
        return callOutView
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    // Hide the callout
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        // Optionally handle taps on the callout.
        print("Tapped the callout for: \(annotation)")
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
    private func mapView(MapView: MGLMapView!, annotation: MGLAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //https://stackoverflow.com/questions/51904284/how-do-you-create-a-custom-callout-for-mapbox-annotations
        //        if control == annotation.rightCalloutAccessoryView {
        //            performSegue(withIdentifier: "AirportInfoSegue", sender: self)
        //            print("Opening AirportInfoViewController")
        //        }
    }
    
    // Substitute our custom view for the user location annotation
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            return GliderUserLocationAnnotationView()
        }
        return nil
    }
    
    // Map finished loading
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        // Center Map to User Location
        // Check if User Location is available.
        // If yes, set Center the Map to User Location
        if let currentLocation = self.currentLocation {
            mapView.showsUserLocation = true
            mapView.setCenter(CLLocationCoordinate2D(
            latitude: currentLocation.coordinate.latitude,
            longitude: currentLocation.coordinate.longitude),
                          zoomLevel: 9.6,
                          animated: true)
        }
        // If not, set Center the Map to Airport Stuttgart
        else {
            mapView.setCenter(CLLocationCoordinate2D(
            latitude: 48.689497,
            longitude: 9.219885),
                          zoomLevel: 9.6,
                          animated: true)
        }

        userLocationButton.updateArrowForTrackingMode(state: userFollow)
        
    }
    
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
        
        // Current Altitude and Location depending stuff
        // Altitude
        updateAltitudeLabel()
        
        // Speed
        updateSpeedLabel()
        
        // Steering Course
        updateCourseLabel()
        
        // Direction
        updateDirectionLabelsAndLine()
        
        // Operating Stuff
        // Gear Warning
        FlightComputer.shared.gearWarning()
        
        // Oxygen Warning
        FlightComputer.shared.oxygenWarning()
        
        // FlightRecorder
        FlightRecorder.shared.addFlightRecorderEntryForLocation(currentLocation)
        
        // updateFlightRecorderLine()
        drawTrackingRoute()
        
    }
    
    // Check for Location Authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}

// MARK: - MapScreen:UIGestureRecognizerDelegate
extension MapScreen:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
