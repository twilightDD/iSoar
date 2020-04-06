//
//  MapScreenViewController.swift
//  Glider Tool
//
//  Created by Denis Leupold on 8/24/18.
//  Copyright © 2018 Denis Leupold. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import Mapbox

// MARK: MapScreen
class MapScreenViewController: UIViewController {
    
    static private var shared: MapScreenViewController?
    
    // MARK: IBOutlets
    @IBOutlet private weak var mapView: MGLMapView!
    @IBOutlet private weak var courseLabel: UILabel!
    @IBOutlet private weak var altitudeLabel: UILabel!
    @IBOutlet private weak var speedLabel: UILabel!
    @IBOutlet private weak var destinationAirportICAOLabel: UILabel!
    @IBOutlet private weak var destinationAirportDistanceLabel: UILabel!
    @IBOutlet private weak var destinationAirportAltitudeLabel: UILabel!
    
    // MARK: Lets and Vars
    
    lazy private var userLocationButton: UserLocationButton = createUserLocationButton()
    
    private var currentDestinationAirportDirectionLine: MGLPolyline?
    private var travelledFlightLine = MGLPolyline()
    private var currentTaskLine: MGLPolyline?

    private var userTrackingMode = true
    private var userFollow = false
    
    private var showAltitudeInMeters = true
    private var altitudeInMeters: CLLocationDistance = 0
    
    private var showSpeedInKMH = true
    private var speedInKMH: CLLocationSpeed = 0
    
    private var showDistanceInKM = true
    
    private var showTrackingRoute = false

    private var nearbyGliderAnnotations = [String: NearbyGliderAnnotation]()
    
    // MARK: - Init & Co.
    override func viewDidLoad() {
        super.viewDidLoad()

        FlightComputer.start()
        OGNSocketConnectionManager.registerForSocketUpdates(self)
        OGNSocketConnectionManager.start()
        LocationManager.registerForLocationUpdates(self)
        TasksDatabase.registerForTaskUpdates(self)
        
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

    func createUserLocationButton()
        -> UserLocationButton {
            let userLocationButton = UserLocationButton(buttonSize: 40)
            userLocationButton.addTarget(self, action: #selector(self.locationButtonTappedAction), for: .touchUpInside)
            userLocationButton.tintColor = self.mapView.tintColor
            
            // Setup constraints such that the button is placed within
            // the upper left corner of the view.
            userLocationButton.translatesAutoresizingMaskIntoConstraints = false
            
            userLocationButton.layer.borderWidth = 1
            userLocationButton.layer.borderColor = UIColor.red.cgColor
            // userLocationButton.layer.cornerRadius = 5

            let leadingConstraint = NSLayoutConstraint(item: userLocationButton,
                                                       attribute: .leading,
                                                       relatedBy: .equal,
                                                       toItem: self.view.safeAreaLayoutGuide,
                                                       attribute: .leading,
                                                       multiplier: 1,
                                                       constant: 10)
            
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
        destinationAirportDistanceLabel.addGestureRecognizer(tapOnDistanceLabelRecognizer)
        destinationAirportDistanceLabel.isUserInteractionEnabled = true
        
        // Destination Airport Label
        let tapOnDestinationAirportLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnDestinationAirportLabel))
        destinationAirportICAOLabel.addGestureRecognizer(tapOnDestinationAirportLabelRecognizer)
        destinationAirportICAOLabel.isUserInteractionEnabled = true
        
    }
    
    // Map Swipe recognized
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            if userFollow == true {
                self.userFollow = false
                userLocationButton.updateArrowForTrackingMode(state: self.userFollow)
            }
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
        updateDestinationAirportDistanceLabel()
    }

    @objc func tapOnDestinationAirportLabel(_ recognizer: UITapGestureRecognizer) {
        if DestinationSelectionViewController.destinationAirport() != nil {
            performSegue(withIdentifier: "AirportInfoSegue", sender: self)
        }
    }
    
    // MARK: - Action Methods
    @IBAction func locationButtonTappedAction(sender: UserLocationButton) {
        self.userFollow = !self.userFollow
        userLocationButton.updateArrowForTrackingMode(state: self.userFollow)
        
        if self.userFollow == true {
            if let currentLocation = LocationManager.currentLocation() {
                self.mapView.setCenter(currentLocation.coordinate,
                                       animated: true)
            }
        }
    }
    
    // MARK: - Private Methods

    private func updateUI() {
        // UI for currentLocation
        updateAltitudeLabel()
        updateSpeedLabel()
        updateCourseLabel()
        drawTrackingRoute()

        // UI for Direction
        updateDestinationAirportUI()
    }

    private func updateAltitudeLabel() {
        guard let currentLocation = LocationManager.currentLocation()
            else { return }
        
        var altituteLabelText = ""
        if showAltitudeInMeters == true {
            altituteLabelText =  String(format: "%.0f m", currentLocation.altitude)
        } else {
            let altitudeInFeet = currentLocation.altitude * 3.28084
            altituteLabelText = String(format: "%.0f ft", altitudeInFeet)
        }
        
        altitudeLabel.text = altituteLabelText
    }

    private func updateSpeedLabel() {
        guard let currentLocation = LocationManager.currentLocation()
            else { return }
        
        var speedLabelText = ""
        
        if currentLocation.speed < 0 {
            speedLabelText = "---"
        } else {
            if showSpeedInKMH == true {
                let speedInKMH = currentLocation.speed * 3.6
                speedLabelText =  String(format: "%.0f km/h", speedInKMH)
            } else {
                let speedInKT = currentLocation.speed * 1.852
                speedLabelText = String(format: "%.0f kt", speedInKT)
            }
        }
        
        speedLabel.text = speedLabelText
    }

    private func updateCourseLabel() {
        guard let currentLocation = LocationManager.currentLocation()
            else {
                self.courseLabel.text = "---"
                return
        }

        let course = currentLocation.course
        if course < 0 {
            self.courseLabel.text = "---"
        } else {
            let courseShort = String(format: "%.0f°", course)
            self.courseLabel.text = courseShort
        }
    }


    // MARK: Route Tracking
    private func checkTrackingRouteStatus() {
        showTrackingRoute = UserDefaultsManager.showTrackingRouteState()
        if showTrackingRoute == true {
            // Delay Drawing and wait for Location
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.mapView.addAnnotation(self.travelledFlightLine)
            }
        } else {
            mapView.removeAnnotation(travelledFlightLine)
        }
    }

    private func drawTrackingRoute() {
        if let currentLocation = LocationManager.currentLocation() {
            var currentLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: currentLocation.coordinate.latitude,
                                                                          longitude: currentLocation.coordinate.longitude)
            travelledFlightLine.appendCoordinates(&currentLocationCoordinate2D,
                                                  count: 1)
        }

    }

    // MARK: Update Destination Airport UI
    private func updateDestinationAirportUI() {
        let destinationAirport = DestinationSelectionViewController.destinationAirport()
        // labels
        updateDestinationAirportICAOLabel(destinationAirport: destinationAirport)
        updateDestinationAirportDistanceLabel()
        updateDestinationAirportAltitudeLabel(destinationAirport: destinationAirport)

        // directionLine
        updateDestinationAirportDirectionLine(destinationAirport: destinationAirport)
    }

    private func updateDestinationAirportICAOLabel(destinationAirport: AirportDatabase.Airport?) {
        if let icaoString = destinationAirport?.icao {
            destinationAirportICAOLabel.text = icaoString
        } else {
            destinationAirportICAOLabel.text = "---"
        }
    }

    private func updateDestinationAirportDistanceLabel() {
        if let currentDistance = DestinationSelectionViewController.distanceToDestinationAirport() {
            var distanceLabelText = ""
            if showDistanceInKM == true {
                let distanceInKm = currentDistance / 1000
                distanceLabelText =  String(format: "%.0f Km", distanceInKm)
            } else {
                let distcanceInMi = currentDistance / 1000 / 1.852
                distanceLabelText = String(format: "%.0f NM", distcanceInMi)
            }

            destinationAirportDistanceLabel.text = distanceLabelText
        } else {
            destinationAirportDistanceLabel.text = "---"
        }
    }
    
    private func updateDestinationAirportAltitudeLabel(destinationAirport: AirportDatabase.Airport?) {
        guard let destinationAirportGuarded = destinationAirport,
            let altitudeDifference = LocationManager.altitudeDifferenceFromCurrentLocationTo(altitude: destinationAirportGuarded.elevation),
            let currentDistance = DestinationSelectionViewController.distanceToDestinationAirport()
            else {
                destinationAirportAltitudeLabel.text = "---"
                destinationAirportAltitudeLabel.textColor = UIColor(red: 150/255,
                                                                    green: 255/255,
                                                                    blue: 255/255,
                                                                    alpha: 1) // TODO: use preset for color; 05042020, ph
                return
        }

        // Get User Default Values
        let safetyAltitude = UserDefaultsManager.safetyAltitude()
        let gliderRatio = UserDefaultsManager.gliderRatio()

        // Glider sink rate to destinationAirport
        let gliderRatioMeter = gliderRatio * 1000       //Gleitzahl in Meter
        let gliderSinkRatePerMeter = 1000 / gliderRatioMeter    //Sinkrate pro Meter
        let gliderSinkRateToDestination = currentDistance * gliderSinkRatePerMeter   //Sinkrate to Destination in Meter

        // Altitude of glider at destinationAirport
        let destinationAltitude = altitudeDifference - safetyAltitude - gliderSinkRateToDestination
        let destinationAltitudeShort = String(format: "%.0f m", destinationAltitude)
        self.destinationAirportAltitudeLabel.text = destinationAltitudeShort

        // Update Text Color
        if destinationAltitude > 0 {
            // TODO: use preset for color; 05042020, ph
            destinationAirportAltitudeLabel.textColor = UIColor(red: 150/255, green: 255/255, blue: 255/255, alpha: 1)
        } else {
            destinationAirportAltitudeLabel.textColor = .red
        }
    }

    private func updateDestinationAirportDirectionLine(destinationAirport unguardedDestinationAirport: AirportDatabase.Airport?) {
        // Do we have a destination and a currentLocation?
        guard let destinationAirport = unguardedDestinationAirport,
            let currentLocationCoordinate2D = LocationManager.currentLocation()?.coordinate
            else {
                // ... if not: remove destinationLine, if existing
                if let destinationAirportDirectionLine = currentDestinationAirportDirectionLine {
                    mapView.remove(destinationAirportDirectionLine)
                    currentDestinationAirportDirectionLine = nil
                }
                return
        }

        // ... if yes: update exsting respective create new destinationLine

        // get new directionLineLocationCoordinate2Ds
        let destinationAirportCoordinate2D = destinationAirport.locationCoordinate2D()
        let directionLineLocationCoordinate2Ds = [currentLocationCoordinate2D, destinationAirportCoordinate2D]
        let pointer = UnsafeMutablePointer(mutating: directionLineLocationCoordinate2Ds)

        if let existingDestinationAirportDirectionLine = currentDestinationAirportDirectionLine {
            existingDestinationAirportDirectionLine.setCoordinates(pointer,
                                                                   count: UInt(directionLineLocationCoordinate2Ds.count))
            currentDestinationAirportDirectionLine = existingDestinationAirportDirectionLine
        } else {
            // neu
            let newDestinationAirportDirectionLine = MGLPolyline.init(coordinates: pointer,
                                                                      count: UInt(directionLineLocationCoordinate2Ds.count))
            mapView.add(newDestinationAirportDirectionLine)
            currentDestinationAirportDirectionLine = newDestinationAirportDirectionLine
        }
    }

}

// MARK: - MGLMapViewDelegate methods
extension MapScreenViewController: MGLMapViewDelegate {
    
    // Set the Direction Line color
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape)
        -> UIColor {
            return UIColor.blue
    }
    
    // Set the Direction Line width
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline)
        -> CGFloat {
            return 2.0
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation)
        -> Bool {
            return true
    }

    // Instantiate and return our custom callout view
    // https://stackoverflow.com/questions/26713582/didselectannotationview-not-called
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation)
        -> MGLCalloutView? {

            if let nearbyGliderAnnotation = annotation as? NearbyGliderAnnotation {
                let views = Bundle.main.loadNibNamed(NearbyGliderCalloutView.nibName(),
                                                     owner: nil,
                                                     options: nil)

                guard let nearbyGliderCalloutView = views?[0] as? NearbyGliderCalloutView
                    else { fatalError("Must be a NearbyGliderCalloutView.") }

                nearbyGliderCalloutView.representedObject = nearbyGliderAnnotation

                return nearbyGliderCalloutView
            }

            return nil
    }

    // Hide the callout
    func mapView(_ mapView: MGLMapView,
                 annotation: MGLAnnotation,
                 calloutAccessoryControlTapped control: UIControl) {
        print("Tapped the calloutAccessoryControlTapped for: \(annotation)")
        mapView.deselectAnnotation(annotation, animated: true)
    }

    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        // Optionally handle taps on the callout.
        print("Tapped the callout for: \(annotation)")
        mapView.deselectAnnotation(annotation, animated: true)
    }

    // Substitute our custom view for the user location annotation
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation)
        -> MGLAnnotationView? {

            var annotationView: MGLAnnotationView?

            // User Annotation -> myself
            if annotation is MGLUserLocation && mapView.userLocation != nil {
                annotationView = GliderUserLocationAnnotationView()
            } else if annotation is NearbyGliderAnnotation {
                // Notice: nil is needed here! MGLAnnotation is an ObjC-Protocol. Fuck it!; 19.3.2020, ph
                guard let flarmID = annotation.title ?? nil
                    else { return nil }

                annotationView = NearbyGliderAnnotationView(annotation: annotation,
                                                            reuseIdentifier: flarmID)
                annotationView!.bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
            }

            return annotationView
    }
    
    // Map finished loading
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        // Center Map to User Location
        // Check if User Location is available.
        // If yes, set Center the Map to User Location
        if let currentLocation = LocationManager.currentLocation() {
            mapView.showsUserLocation = true
            mapView.setCenter(CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude,
                                                     longitude: currentLocation.coordinate.longitude),
                              zoomLevel: Presets.MapScreen.zoomLevel,
                              animated: true)
        }
            // If not, set Center the Map to Airport Stuttgart
        else {
            mapView.setCenter(CLLocationCoordinate2D(latitude: 48.689497,
                                                     longitude: 9.219885),
                              zoomLevel: Presets.MapScreen.zoomLevel,
                              animated: true)
        }
        
        userLocationButton.updateArrowForTrackingMode(state: userFollow)
    }
    
}

// MARK: - Extension - LocationManagerDelegate
extension MapScreenViewController: LocationManagerDelegate {
    
    func locationManager(didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last // Alternativ: LocationManager.currentLocation
            else { return }

        // Get User Tracking State - If true - set Map center on User Location
        if self.userFollow == true {
            self.mapView.setCenter(currentLocation.coordinate, animated: true)
        }

        updateUI()
    }

}

// MARK: - Extension - TasksDatabaseProtocol
extension MapScreenViewController: TasksDatabaseProtocol {

    func newTask(withCoordinates coordinates: [CLLocationCoordinate2D]) {
        if let currentTaskLine = currentTaskLine {
            mapView.removeAnnotation(currentTaskLine)
            self.currentTaskLine = nil
        }

        if coordinates.isEmpty == false {
            currentTaskLine = MGLPolyline(coordinates: coordinates,
                                          count: UInt(coordinates.count))
            if let currentTaskLine = currentTaskLine {
                mapView.addAnnotation(currentTaskLine)
            }
        }
    }
}

// MARK: - MapScreen:UIGestureRecognizerDelegate
extension MapScreenViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MapScreenViewController: DL_OGNSocketConnectionManagerDelegate {

    func updateNearbyGlider(gliderTelemetryData: GliderTelemetryData) {
        var nearbyGliderAnnotation = nearbyGliderAnnotations[gliderTelemetryData.flarmID]
        if nearbyGliderAnnotation == nil {
            nearbyGliderAnnotation = NearbyGliderAnnotation.init(gliderTelemetryData: gliderTelemetryData)
            nearbyGliderAnnotations[gliderTelemetryData.flarmID] = nearbyGliderAnnotation
            mapView.addAnnotation(nearbyGliderAnnotation!)
        }

        nearbyGliderAnnotation!.gliderTelemetryData = gliderTelemetryData
    }

    func removeNearbyGlider(gliderTelemetryData: GliderTelemetryData) {
        if let nearbyGliderAnnotation = nearbyGliderAnnotations[gliderTelemetryData.flarmID] {
            mapView.removeAnnotation(nearbyGliderAnnotation)
            nearbyGliderAnnotations[gliderTelemetryData.flarmID] = nil
        }
    }

    func removeAllNearbyGlider() {
        var nearbyGliderAnnotationsToRemove = [NearbyGliderAnnotation]()
        for (_, nearbyGliderAnnotationToRemove) in nearbyGliderAnnotations {
            nearbyGliderAnnotationsToRemove.append(nearbyGliderAnnotationToRemove)
        }

        mapView.removeAnnotations(nearbyGliderAnnotationsToRemove)
        nearbyGliderAnnotations.removeAll()
    }
    
}
