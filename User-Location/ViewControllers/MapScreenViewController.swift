//
//  MapScreenViewController.swift
//  Glider Tool
//
//  Created by Denis Leupold on 8/24/18.
//  Copyright © 2018 Denis Leupold. All rights reserved.
//

import UIKit
import CoreLocation
import Mapbox

// MARK: MapScreen
class MapScreenViewController: UIViewController {
    
    static private var shared = MapScreenViewController()
    
    // MARK: IBOutlets
    @IBOutlet private weak var mapView: MGLMapView!
    @IBOutlet private weak var courseLabel: UILabel!
    @IBOutlet private weak var altitudeLabel: UILabel!
    @IBOutlet private weak var speedLabel: UILabel!
    @IBOutlet private weak var destinationAirportICAOLabel: UILabel!
    @IBOutlet private weak var distanceToDestinationAirportLabel: UILabel!
    @IBOutlet private weak var altitudeAtDestinationLabel: UILabel!
    
    // MARK: Lets and Vars
    lazy private var userLocationButton: UserLocationButton = createUserLocationButton()
    
    // Text Label Attributes
    private let valueLabelTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)]
    private let unitLabelTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
    
    private var currentDestinationAirportDirectionLine: MGLPolyline?
    private var currentTravelledFlightLineSegemt = MGLPolyline()
    private var travelledFlightlineSegments = [MGLPolyline]()
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
    private var airportAnnotationArray = [MGLPointAnnotation]()
    
    private var verticalMovement: String = ""
    
    private var mapIsInCirclingZoom: Bool = false
    
    private var userAcceptedEULA: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    // MARK: - Init & Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MapScreenViewController.shared = self
        
        FlightComputer.start()
        FlightComputer.registerForFlightComputerUpdates(self)
        
        FlightRecorder.setup()
        
        OGNSocketConnectionManager.registerForSocketUpdates(self)
        OGNSocketConnectionManager.start()
        LocationManager.registerForLocationUpdates(self)
        TasksDatabase.registerForTaskUpdates(self)
        
        setupMapBox()
        
        setupGestureRecognizers()
        
        createAirportAnnotations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkIfMapStyleURLHasChanged()
        
        checkTrackingRouteStatus()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Class Methods
    class func increaseZoomLevel() {
        let shared = MapScreenViewController.shared
        
        // Save current Zoom Level to User Defaults
        UserDefaultsManager.set(userMapZoomLevel: shared.mapView.zoomLevel)
        
        // Zoom into Map
        shared.mapView.setZoomLevel(13, animated: true)
        
    }
    
    class func decreaseZoomLevel() {
        let shared = MapScreenViewController.shared
        
        // Read Zoom Level from User Defaults and set Zoom Level to Map
        shared.mapView.setZoomLevel(UserDefaultsManager.userMapZoomLevel(), animated: true)
        
    }
    // MARK: - Setup functions
    func setupMapBox() {
        
        guard let mapStyleURL: URL = URL(string: UserDefaultsManager.mapStyleURL()) else { return }
        
        self.mapView.styleURL = mapStyleURL
        
        mapView.delegate = self
        
        mapView.tintColor = .red
        mapView.allowsRotating = false
        mapView.allowsTilting = false
        mapView.compassView.isHidden = true
        mapView.minimumZoomLevel = 4
        mapView.maximumZoomLevel = 13
        
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
    
    // Create Annotations for Airports on Map
    func createAirportAnnotations() {
        if let destinationAirportArray = AirportDatabase.destinationAirports() {
            for airport in destinationAirportArray {
                let airportAnnotation = AirportAnnotation.init(airport: airport)
                airportAnnotationArray.append(airportAnnotation)
            }
            mapView.addAnnotations(airportAnnotationArray)
        }
    }
    
    // Create User Center Location Button on Map
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
        mapView.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(screenZoomed(_:)))
        pinchGestureRecognizer.delegate = self
        mapView.addGestureRecognizer(pinchGestureRecognizer)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(screenDoubleTapped))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delegate = self
        mapView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        mapView.isUserInteractionEnabled = true
        
        // Altitude Label
        let tapOnAltitudeLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnAltitudeLabel))
        altitudeLabel.addGestureRecognizer(tapOnAltitudeLabelRecognizer)
        altitudeLabel.isUserInteractionEnabled = true
        
        // Speed Label
        let tapOnSpeedLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnSpeedLabel))
        speedLabel.addGestureRecognizer(tapOnSpeedLabelRecognizer)
        speedLabel.isUserInteractionEnabled = true
        
        // Distance to Destination Airport Label
        let tapOnDistanceToDestinationAirportLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnDistanceToDestinationAirportLabel))
        distanceToDestinationAirportLabel.addGestureRecognizer(tapOnDistanceToDestinationAirportLabelRecognizer)
        distanceToDestinationAirportLabel.isUserInteractionEnabled = true
        
        // Destination Airport ICAO Label
        let tapOnDestinationAirportLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnDestinationAirportLabel))
        destinationAirportICAOLabel.addGestureRecognizer(tapOnDestinationAirportLabelRecognizer)
        destinationAirportICAOLabel.isUserInteractionEnabled = true
        
    }
    
    // Map Swipe recognized
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            // print("Swipe detected")
            if userFollow == true {
                self.userFollow = false
                userLocationButton.updateArrowForTrackingMode(state: self.userFollow)
            }
        }
    }
    
    // Map Zoom recognized
    @objc func screenZoomed(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .ended {
            // print("Zoom regognized")
            if userFollow == true {
                self.userFollow = false
                userLocationButton.updateArrowForTrackingMode(state: self.userFollow)
                UserDefaultsManager.set(userMapZoomLevel: mapView.zoomLevel)
            } else {
                UserDefaultsManager.set(userMapZoomLevel: mapView.zoomLevel)
            }
        }
    }
    
    // Map Double-Tap recognized
    @objc func screenDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            //print("Doube-Tap regognized")
            if userFollow == true {
                self.userFollow = false
                userLocationButton.updateArrowForTrackingMode(state: self.userFollow)
                UserDefaultsManager.set(userMapZoomLevel: mapView.zoomLevel)
            } else {
                UserDefaultsManager.set(userMapZoomLevel: mapView.zoomLevel)
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
    
    @objc func tapOnDistanceToDestinationAirportLabel(_ recognizer: UITapGestureRecognizer) {
        showDistanceInKM = !showDistanceInKM
        updateDestinationAirportDistanceLabel()
    }
    
    @objc func tapOnDestinationAirportLabel(_ recognizer: UITapGestureRecognizer) {
        if FlightComputer.selectedDestinationAirport() != nil {
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
    
    // Download updated Airport Database File from Server
    private func showEULAConfirmationPopup() {
        if userAcceptedEULA == false {
            let alert = UIAlertController(title: "Software Usage Agreement",
                                          message: Presets.MapScreen.eulaText,
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Confirm",
                                          style: .default,
                                          handler: { action in
                                            self.userAcceptedEULA = true
            }))
            
            self.present(alert, animated: true)
        }
        
    }
    
    private func updateUI() {
        // Update UI for currentLocation
        updateAltitudeLabel()
        updateSpeedLabel()
        updateCourseLabel()
        
        // Update UI for flown Route
        drawTrackingRoute()
        
        // Update UI for Direction
        updateDestinationAirportUI()

    }
    
    // Check if User has changed the Map Style in Settings
    private func checkIfMapStyleURLHasChanged() {
        guard let mapStyleURL: URL = URL(string: UserDefaultsManager.mapStyleURL()) else { return }
        
        if mapView.styleURL != mapStyleURL {
            
            MGLOfflineStorage.shared.invalidateAmbientCache { error in
                print("MapBox Tile Cache invalidated")
            }
            
            setupMapBox()
            
        }
    }
    
    private func updateAltitudeLabel() {
        guard let currentLocation = LocationManager.currentLocation()
            else { return }
        
        var altituteLabelValueText = ""
        var altituteLabelUnitText = ""
        
        if showAltitudeInMeters == true {
            altituteLabelValueText = String(format: "%.0f", currentLocation.altitude)
            altituteLabelUnitText = " m"
        } else {
            let altitudeInFeet = currentLocation.altitude * 3.28084
            altituteLabelValueText = String(format: "%.0f", altitudeInFeet)
            altituteLabelUnitText = " ft"
        }
        
        let valueString = NSMutableAttributedString(string: altituteLabelValueText, attributes: valueLabelTextAttributes)
        let unitString = NSMutableAttributedString(string: altituteLabelUnitText, attributes: unitLabelTextAttributes)
        
        valueString.append(unitString)
        
        altitudeLabel.attributedText = valueString
    }
    
    private func updateSpeedLabel() {
        guard let currentLocation = LocationManager.currentLocation()
            else { return }
        
        var speedLabelValueText = ""
        var speedLabelUnitText = ""
        
        if currentLocation.speed < 0 {
            speedLabelValueText = "---"
        } else {
            if showSpeedInKMH == true {
                let speedInKMH = currentLocation.speed * 3.6
                speedLabelValueText =  String(format: "%.0f", speedInKMH)
                speedLabelUnitText = " km/h"
            } else {
                let speedInKT = currentLocation.speed * 1.9438
                speedLabelValueText = String(format: "%.0f", speedInKT)
                speedLabelUnitText = " kt"
            }
        }
        
        let valueString = NSMutableAttributedString(string: speedLabelValueText, attributes: valueLabelTextAttributes)
        let unitString = NSMutableAttributedString(string: speedLabelUnitText, attributes: unitLabelTextAttributes)
        
        valueString.append(unitString)
        
        speedLabel.attributedText = valueString
        
    }
    
    private func updateCourseLabel() {
        guard let currentLocation = LocationManager.currentLocation()
            else { return }
        
        var courseLabelValueText = ""
        var courseLabelUnitText = ""
        
        let course = currentLocation.course
        if course < 0 {
            courseLabelValueText = "---"
        } else {
            courseLabelValueText = String(format: "%.0f", course)
            courseLabelUnitText = "°"
        }
        
        let valueString = NSMutableAttributedString(string: courseLabelValueText, attributes: valueLabelTextAttributes)
        let unitString = NSMutableAttributedString(string: courseLabelUnitText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.baselineOffset: 7])
        
        valueString.append(unitString)
        
        courseLabel.attributedText = valueString
        
    }
    
    // MARK: Route Tracking
    // Check for Tracking Route Status
    private func checkTrackingRouteStatus() {
        showTrackingRoute = UserDefaultsManager.showTrackingRouteState()
        if showTrackingRoute == true {
            addTravelledFlightLineToMapView()
        } else {
            removeTravelledFlightLineFromMapView()
        }
    }
    
    // Add Travelled FlightLine to MapView
    private func addTravelledFlightLineToMapView() {
        for segment in travelledFlightlineSegments {
            mapView.addAnnotation(segment)
        }
    }
    
    // Remove Travelled FlightLine from MapView
    private func removeTravelledFlightLineFromMapView() {
        for segment in travelledFlightlineSegments {
            mapView.removeAnnotation(segment)
        }
    }
    
    // TODO: 20200511 Code Optimieren! Doppelungen raus! Enum für ascanding & descanding
    private func drawTrackingRoute() {
        if FlightComputer.isGliderFlying() == true,
            let currentLocation = LocationManager.currentLocation(),
            let formerLocation = LocationManager.formerLocation() {
            
            var formerLocationCoordinate2D = formerLocation.coordinate
            var currentLocationCoordinate2D = currentLocation.coordinate
            
            // If former Altitude was lesser than the current Altitude - Glider is ascanding
            if formerLocation.altitude <= currentLocation.altitude {
                //print("Former: \(formerLocation?.altitude) <= Current: \(currentLocation.altitude) = Steigen")
                // If the glider descended before, but is now ascending
                if verticalMovement != "ascanding" {
                    // Create new Polyline from former Location...
                    //print("Erstelle neue Polyline von der letzten Position")
                    let ascandingTravelledFlightLine = MGLPolyline.init(coordinates: &formerLocationCoordinate2D, count: 1)
                    // and append current Location to Polyline
                    //print("und füge Punkt der aktuellen Position hinzu")
                    ascandingTravelledFlightLine.appendCoordinates(&currentLocationCoordinate2D, count: 1)
                    ascandingTravelledFlightLine.title = "ascanding"
                    currentTravelledFlightLineSegemt = ascandingTravelledFlightLine
                    travelledFlightlineSegments.append(ascandingTravelledFlightLine)
                    
                    if UserDefaultsManager.showTrackingRouteState() == true {
                        self.mapView.addAnnotation(currentTravelledFlightLineSegemt)
                    }
                    
                    // If the glider already acanded before
                } else {
                    // just append current Location to Polyline
                    //print("Füge nur Punkt hinzu")
                    currentTravelledFlightLineSegemt.appendCoordinates(&currentLocationCoordinate2D, count: 1)
                }
                
                // Set verticalMovement to "ascanding"
                verticalMovement = "ascanding"
                
                // If former Altitude was greater than the current Altitude - Glider is desscanding
            } else {
                //print("Former: \(formerLocation?.altitude) >= Current: \(currentLocation.altitude) = Sinken")
                // If the glider acscended before, but is now desscending
                if verticalMovement != "descanding" {
                    // Create new Polyline from former Location...
                    //print("Erstelle neue Polyline von der letzten Position")
                    let descandingTravelledFlightLine = MGLPolyline.init(coordinates: &formerLocationCoordinate2D, count: 1)
                    // and append current Location to Polyline
                    //print("und füge Punkt der aktuellen Position hinzu")
                    descandingTravelledFlightLine.appendCoordinates(&currentLocationCoordinate2D, count: 1)
                    descandingTravelledFlightLine.title = "descanding"
                    currentTravelledFlightLineSegemt = descandingTravelledFlightLine
                    travelledFlightlineSegments.append(descandingTravelledFlightLine)
                    if UserDefaultsManager.showTrackingRouteState() == true {
                        self.mapView.addAnnotation(currentTravelledFlightLineSegemt)
                    }
                    // If the glider already descanded before
                } else {
                    // just append current Location to Polyline
                    //print("Füge nur Punkt hinzu")
                    self.currentTravelledFlightLineSegemt.appendCoordinates(&currentLocationCoordinate2D, count: 1)
                }
                
                // Set verticalMovement to "descanding"
                verticalMovement = "descanding"
                
            }
            
            // TODO: DOCU
            
        }
        
    }
    
    // MARK: Update Destination Airport UI
    private func updateDestinationAirportUI() {
        guard let destinationAirport = FlightComputer.selectedDestinationAirport(),
            let _ = LocationManager.currentLocation()
            else {
                resetUpdateDestinationAirportUI()
                return
        }
        
        // Destination Airport Labels
        // TODO: 20200519 ICAO Label muss nicht bei jedem Location Update neu gezeichnet werden
        updateDestinationAirportICAOLabel(destinationAirport: destinationAirport)
        updateDestinationAirportDistanceLabel()
        updateDestinationAirportAltitudeLabel(destinationAirport: destinationAirport)
        
        // DirectionLine
        updateDestinationAirportDirectionLine(destinationAirport: destinationAirport)
    }
    
    private func resetUpdateDestinationAirportUI() {
        // labels
        destinationAirportICAOLabel.text = "---"
        distanceToDestinationAirportLabel.text = "---"
        altitudeAtDestinationLabel.text = "---"
        altitudeAtDestinationLabel.textColor = UIColor(named: "StandardTextColor")
        
        // directionLine
        if let destinationAirportDirectionLine = currentDestinationAirportDirectionLine {
            mapView.remove(destinationAirportDirectionLine)
            currentDestinationAirportDirectionLine = nil
        }
    }
    
    private func updateDestinationAirportICAOLabel(destinationAirport: AirportDatabase.Airport) {
        destinationAirportICAOLabel.text = destinationAirport.icao
    }
    
    private func updateDestinationAirportDistanceLabel() {
        if let currentDistance = DestinationSelectionViewController.distanceToDestinationAirport() {
            var distanceLabelValueText = ""
            var distanceLabelUnitText = ""
            if showDistanceInKM == true {
                let distanceInKm = currentDistance / 1000
                distanceLabelValueText =  String(format: "%.0f", distanceInKm)
                distanceLabelUnitText = " Km"
            } else {
                let distcanceInMi = currentDistance / 1000 / 1.852
                distanceLabelValueText = String(format: "%.0f", distcanceInMi)
                distanceLabelUnitText = " NM"
            }
            
            let valueString = NSMutableAttributedString(string: distanceLabelValueText, attributes: valueLabelTextAttributes)
            let unitString = NSMutableAttributedString(string: distanceLabelUnitText, attributes: unitLabelTextAttributes)
            
            valueString.append(unitString)
            
            distanceToDestinationAirportLabel.attributedText = valueString
            
        } else {
            distanceToDestinationAirportLabel.text = "---"
        }
    }
    
    private func updateDestinationAirportAltitudeLabel(destinationAirport: AirportDatabase.Airport) {
        guard let altitudeDifference = LocationManager.altitudeDifferenceFromCurrentLocationTo(altitude: destinationAirport.elevation),
            let currentDistance = DestinationSelectionViewController.distanceToDestinationAirport()
            else { return }
        
        // Get User Default Values
        let safetyAltitude = UserDefaultsManager.safetyAltitude()
        let gliderRatio = UserDefaultsManager.gliderRatio()
        
        // Calculate descended Meters to Destination
        let gliderRatioMeter = gliderRatio * 1000   // Gleitzahl in Meter
        let gliderSinkRatePerMeter = 1000 / gliderRatioMeter    // Sinkrate pro Meter
        let descendedMetersToDestination = currentDistance * gliderSinkRatePerMeter // Descended Meters to Destination
        
        // Calculate the Altitude of the Glider at Destination
        let altitudeAtDestination = altitudeDifference - safetyAltitude - descendedMetersToDestination
        let altitudeAtDestinationLabelValueText = String(format: "%.0f", altitudeAtDestination)
        let altitudeAtDestinationLabelUnitText = " m"
        
        let valueString = NSMutableAttributedString(string: altitudeAtDestinationLabelValueText, attributes: valueLabelTextAttributes)
        let unitString = NSMutableAttributedString(string: altitudeAtDestinationLabelUnitText, attributes: unitLabelTextAttributes)
        
        valueString.append(unitString)
        
        altitudeAtDestinationLabel.attributedText = valueString
        
        // Update Text Color
        if altitudeAtDestination > 0 {
            altitudeAtDestinationLabel.textColor = UIColor(named: "StandardTextColor")
        } else {
            altitudeAtDestinationLabel.textColor = UIColor(named: "WarningTextColor")
        }
    }
    
    private func updateDestinationAirportDirectionLine(destinationAirport: AirportDatabase.Airport) {
        guard let currentLocationCoordinate2D = LocationManager.currentLocation()?.coordinate
            else { return }
        
        // get new directionLineLocationCoordinate2Ds
        let destinationAirportCoordinate2D = destinationAirport.locationCoordinate2D()
        let directionLineLocationCoordinate2Ds = [currentLocationCoordinate2D,
                                                  destinationAirportCoordinate2D]
        let pointer = UnsafeMutablePointer(mutating: directionLineLocationCoordinate2Ds)
        
        // Update existing or create new line
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
            if annotation.title == "ascanding" {
                return UIColor.green
            } else if annotation.title == "descanding" {
                return UIColor.orange
            } else if annotation == currentTaskLine {
                return UIColor.systemPink
            }
            
            return UIColor.blue
            
    }
    
    // Set the Direction Line width
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline)
        -> CGFloat {
            return 2.0
    }
    
    // Annotation can show Callout
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation)
        -> Bool {
            if annotation is AirportAnnotation {
                return false
            } else {
                return true
            }
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
    
    // Substitute our custom view for the user location annotation
    // TODO: 20200526 if und if else´s prüfen
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation)
        -> MGLAnnotationView? {
            
            var annotationView: MGLAnnotationView?
            
            // User Annotation -> myself
            if annotation is MGLUserLocation && mapView.userLocation != nil {
                annotationView = UserLocationAnnotationView()
            } else if annotation is NearbyGliderAnnotation {
                // Notice: nil is needed here! MGLAnnotation is an ObjC-Protocol. Fuck it!; 19.3.2020, ph
                guard let flarmID = annotation.title ?? nil
                    else { return nil }
                
                annotationView = NearbyGliderAnnotationView(annotation: annotation,
                                                            reuseIdentifier: flarmID)
                annotationView!.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
                
                return annotationView
                
            } else if annotation is AirportAnnotation {
                // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
                let reuseIdentifier = "\(annotation.coordinate.longitude)"
                
                // For better performance, always try to reuse existing annotations.
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
                
                // If there’s no reusable annotation view available, initialize a new one.
                if annotationView == nil {
                    annotationView = AirportAnnotationView(reuseIdentifier: reuseIdentifier)
                    annotationView!.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
                    
                }
                
                return annotationView
            }
            
            return annotationView
    }
    
    // User did select Annotation
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        guard let title = annotation.title ?? nil,
            let subtitle = annotation.subtitle ?? nil
            else { return }
        
        if let airportAnnotation = annotation as? AirportAnnotation {
            // If selected Airport is ALREADY the Destination Airport
            if airportAnnotation.airport == FlightComputer.selectedDestinationAirport() {
                //Create AlertViewController
                let alertController = UIAlertController(title: (subtitle),
                                                        message: "Please choose an option for \(title)",
                    preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Cancel Route",
                                                        style: .destructive,
                                                        handler: { [unowned self] _ in
                                                            self.mapView.deselectAnnotation(annotation, animated: true)
                                                            FlightComputer.setSelectedDestinationAirport(nil)
                }))
                
                alertController.addAction(UIAlertAction(title: "Dismiss",
                                                        style: .cancel,
                                                        handler: { [unowned self] _ in
                                                            self.mapView.deselectAnnotation(annotation, animated: true)
                }))
                
                // Present UIAlertController
                self.present(alertController, animated: true, completion: {
                })
                
                // If selected Airport is NOT the Destination Airport
            } else {
                //Create AlertViewController
                let alertController = UIAlertController(title: (subtitle),
                                                        message: "Please choose an option for \(title)",
                    preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Destination",
                                                        style: .destructive,
                                                        handler: { [unowned self] _ in
                                                            self.mapView.deselectAnnotation(annotation, animated: true)
                                                            FlightComputer.setSelectedDestinationAirport(airportAnnotation.airport)
                }))
                
                alertController.addAction(UIAlertAction(title: "Dismiss",
                                                        style: .cancel,
                                                        handler: { [unowned self] _ in
                                                            self.mapView.deselectAnnotation(annotation, animated: true)
                }))
                
                // Present UIAlertController
                #if DEBUG
                print("Select Airport on Map is deactivated in Debug Mode")
                return
                #else
                self.present(alertController, animated: true, completion: {
                })
                #endif
                
            }
        }
    }
    
    // Map did finished loading
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        // Center Map to User Location
        // Check if User Location is available.
        // If yes, set Center the Map to User Location
        if let currentLocation = LocationManager.currentLocation() {
            mapView.showsUserLocation = true
            mapView.setCenter(CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude,
                                                     longitude: currentLocation.coordinate.longitude),
                              zoomLevel: UserDefaultsManager.userMapZoomLevel(),
                              animated: true)
        }
            // If not, set Center the Map to Airport Stuttgart
        else {
            mapView.setCenter(CLLocationCoordinate2D(latitude: 48.689497,
                                                     longitude: 9.219885),
                              zoomLevel: UserDefaultsManager.userMapZoomLevel(),
                              animated: true)
        }
        
        userLocationButton.updateArrowForTrackingMode(state: userFollow)
        
        showEULAConfirmationPopup()
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

// MARK: - MapScreen:DL_OGNSocketConnectionManagerDelegate
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
    
    func removeAllNearbyGliders() {
        var nearbyGliderAnnotationsToRemove = [NearbyGliderAnnotation]()
        for (_, nearbyGliderAnnotationToRemove) in nearbyGliderAnnotations {
            nearbyGliderAnnotationsToRemove.append(nearbyGliderAnnotationToRemove)
        }
        
        mapView.removeAnnotations(nearbyGliderAnnotationsToRemove)
        nearbyGliderAnnotations.removeAll()
    }
    
}

// MARK: - MapScreen: FlightComputerDelegate
extension MapScreenViewController: FlightComputerDelegate {
    func gliderIsFlying(_ isFlying: Bool) {
        if isFlying == true {
            // Remove all existing travelledFlightlineSegments Annotations from MapScreen
            removeTravelledFlightLineFromMapView()
            // Remove all existing Polyline-Location-Points from Array
            travelledFlightlineSegments.removeAll()
        }
    }
}
