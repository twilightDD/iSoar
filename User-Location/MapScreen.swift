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
    
    @IBOutlet weak var mapView: MKMapView!
    //@IBOutlet weak var altitude: UILabel!
    @IBOutlet weak var speed: UILabel!

    @IBOutlet weak var altitudeShort: UILabel!

    @IBOutlet weak var courseShort: UILabel!
    
    
    @IBOutlet weak var glidepathShort: UILabel!
    
    
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000

    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
        //Prevent Display to fall asleep
        UIApplication.shared.isIdleTimerDisabled = true
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
}


extension MapScreen: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    
        let altitude = location.altitude
        let altitudeShort = String(format: "%.0f m", altitude)
        self.altitudeShort.text = altitudeShort

        let speed = location.speed
        self.speed.text = "\(speed) mps"
        
        
        let course = location.course
        let courseShort = String(format: "%.0f °", course)
        self.courseShort.text = courseShort
        
        let safetyHeight: Double = 200                  //Sicherheitshöhe
        let destinationHeight: Double = 421             //Höhe EDSR

        let glidepath = altitude-destinationHeight-safetyHeight
        let glidepathShort = String(format: "%.0f m", glidepath)
        self.glidepathShort.text = glidepathShort

        

    
        print("Altitude: \(altitudeShort)")
        print("Course: \(courseShort)")
        print("Glidepath: \(glidepathShort)")
        
    }
    

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
