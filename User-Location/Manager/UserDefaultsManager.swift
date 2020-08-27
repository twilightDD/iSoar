//
//  UserDefaultsManager.swift
//  Glider Tool
//
//  Created by Peter Hauke on 22.01.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    // MARK: - Keys
    private static let CollisionWarningStateKey = "collisionWarningState"
    private static let GliderRatioKey = "gliderRatio"
    private static let GliderIDKey = "gliderID"
    private static let OwnFlarmIDKey = "ownFlarmID"
    private static let GearWarningStateKey = "gearWarningState"
    private static let SafetyAltitudeKey = "safetyAltitude"
    private static let ShowAllNearbyGlidersStateKey = "showAllNearbyGlidersState"
    private static let ShowOnlyBuddyStateKey = "showOnlyBuddyState"
    private static let ShowTrackingRouteStateKey = "showTrackingRouteState"
    private static let TrafficMonitorRadiusKey = "trafficMonitorRadius"
    private static let CenteringHelpStateKey = "centeringHelpState"
    private static let UserMapZoomLevelKey = "userMapZoomLevel"
    private static let MapCountryKey = "mapCountry"
    
    // MARK: - Defaults
    private static let gliderIDDefault = "D-XXXX"
    private static let ownFlarmIDDefault = "FLRxxxxxx"
    private static let gliderRadioDefault: Double = 30
    private static let gearWarningSwitchDefault: Bool = true
    private static let safetyAltitudeDefault: Double = 300
    private static let showTrackingRouteSwitchDefault: Bool = true
    private static let showFlarmBuddySwitchDefault: Bool = true
    private static let showNearbyGlidersSwitchDefault: Bool = true
    private static let collisionWarningSwitchDefault: Bool = true
    private static let trafficMonitorRadiusDefault: Double = 50
    private static let centeringHelpSwitchDefault: Bool = true
    private static let userMapZoomLevelDefault: Double = 9.6
    private static let mapCountryDefault: String = "Germany"
    
    // MARK: - Lets and Vars
    private static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Public Class Methods
    class func setupUserDefaults() {
        // Check for User Defaults
        if shared.userDefaults.value(forKey: GliderRatioKey) == nil {
            UserDefaultsManager.set(gliderRatio: gliderRadioDefault)
        }
        if shared.userDefaults.value(forKey: SafetyAltitudeKey) == nil {
            UserDefaultsManager.set(safetyAltitude: safetyAltitudeDefault)
        }
        if shared.userDefaults.value(forKey: GliderIDKey) == nil {
            UserDefaultsManager.set(gliderID: gliderIDDefault)
        }
        if shared.userDefaults.value(forKey: OwnFlarmIDKey) == nil {
            UserDefaultsManager.set(ownFlarmID: ownFlarmIDDefault)
        }
        if shared.userDefaults.value(forKey: GearWarningStateKey) == nil {
            shared.userDefaults.set(true, forKey: GearWarningStateKey)
        }
        if shared.userDefaults.value(forKey: ShowTrackingRouteStateKey) == nil {
            shared.userDefaults.set(true, forKey: ShowTrackingRouteStateKey)
        }
        if shared.userDefaults.value(forKey: ShowOnlyBuddyStateKey) == nil {
            shared.userDefaults.set(true, forKey: ShowOnlyBuddyStateKey)
        }
        if shared.userDefaults.value(forKey: ShowAllNearbyGlidersStateKey) == nil {
            shared.userDefaults.set(true, forKey: ShowAllNearbyGlidersStateKey)
        }
        if shared.userDefaults.value(forKey: CollisionWarningStateKey) == nil {
            shared.userDefaults.set(true, forKey: CollisionWarningStateKey)
        }
        if shared.userDefaults.value(forKey: TrafficMonitorRadiusKey) == nil {
            UserDefaultsManager.set(trafficMonitorRadius: trafficMonitorRadiusDefault)
        }
        if shared.userDefaults.value(forKey: CenteringHelpStateKey) == nil {
            shared.userDefaults.set(true, forKey: CenteringHelpStateKey)
        }
        if shared.userDefaults.value(forKey: UserMapZoomLevelKey) == nil {
            UserDefaultsManager.set(userMapZoomLevel: userMapZoomLevelDefault)
        }
        if shared.userDefaults.value(forKey: MapCountryKey) == nil {
            UserDefaultsManager.set(mapCountry: mapCountryDefault)
        }
    }
    
    // MARK: GliderID
    class func gliderID()
        -> String {
            let gliderID = shared.userDefaults.value(forKey: GliderIDKey) as? String ?? gliderIDDefault
            return gliderID
    }
    
    class func set(gliderID value: String) {
        shared.userDefaults.set(value, forKey: GliderIDKey)
    }
    
    // MARK: Own FlarmID
    class func ownFlarmID()
        -> String {
            let ownFlarmID = shared.userDefaults.value(forKey: OwnFlarmIDKey) as? String ?? ownFlarmIDDefault
            return ownFlarmID
    }
    
    class func set(ownFlarmID value: String) {
        shared.userDefaults.set(value, forKey: OwnFlarmIDKey)
    }
    
    // MARK: GliderRatio
    class func gliderRatio()
        -> Double {
            let gliderRatio = shared.userDefaults.value(forKey: GliderRatioKey) as? Double ?? gliderRadioDefault
            return gliderRatio
    }
    
    class func set(gliderRatio: Double) {
        shared.userDefaults.set(gliderRatio, forKey: GliderRatioKey)
    }
    
    // MARK: GearWarningSwitch
    class func gearWarningState()
        -> Bool {
            let gearWarningSwitch = shared.userDefaults.value(forKey: GearWarningStateKey) as? Bool ?? gearWarningSwitchDefault
            return gearWarningSwitch
    }
    
    class func set(gearWarningState: Bool) {
        shared.userDefaults.set(gearWarningState, forKey: GearWarningStateKey)
    }
    
    // MARK: SafetyAltitude
    class func safetyAltitude()
        -> Double {
            let safetyAltitude = shared.userDefaults.value(forKey: SafetyAltitudeKey) as? Double ?? safetyAltitudeDefault
            return safetyAltitude
    }
    
    class func set(safetyAltitude: Double) {
        shared.userDefaults.set(safetyAltitude, forKey: SafetyAltitudeKey)
    }
    
    // MARK: ShowTrackingRouteSwitch
    class func showTrackingRouteState()
        -> Bool {
            let showTrackingRouteSwitchKey = shared.userDefaults.value(forKey: ShowTrackingRouteStateKey) as? Bool ?? showTrackingRouteSwitchDefault
            return showTrackingRouteSwitchKey
    }
    
    class func set(showTrackingRouteState: Bool) {
        shared.userDefaults.set(showTrackingRouteState, forKey: ShowTrackingRouteStateKey)
    }
    
    // MARK: Show Buddy Switch
    class func showOnlyBuddySwitchState()
        -> Bool {
            let showOnlyBuddySwitchKey = shared.userDefaults.value(forKey: ShowOnlyBuddyStateKey) as? Bool ?? showFlarmBuddySwitchDefault
            return showOnlyBuddySwitchKey
    }
    
    class func set(showOnlyBuddySwitchState: Bool) {
        shared.userDefaults.set(showOnlyBuddySwitchState, forKey: ShowOnlyBuddyStateKey)
    }
    
    // MARK: ShowNearbyGlidersSwitch
    class func showAllNearbyGlidersState()
        -> Bool {
            let showNearbyGlidersSwitch = shared.userDefaults.value(forKey: ShowAllNearbyGlidersStateKey) as? Bool ?? showNearbyGlidersSwitchDefault
            return showNearbyGlidersSwitch
    }
    
    class func set(showAllNearbyGlidersState: Bool) {
        shared.userDefaults.set(showAllNearbyGlidersState, forKey: ShowAllNearbyGlidersStateKey)
    }
    
    // MARK: CollisionWarningSwitch
    class func collisionWarningState()
        -> Bool {
            let collisionWarningSwitch = shared.userDefaults.value(forKey: CollisionWarningStateKey) as? Bool ?? collisionWarningSwitchDefault
            return collisionWarningSwitch
    }
    
    class func set(collisionWarningState: Bool) {
        shared.userDefaults.set(collisionWarningState, forKey: CollisionWarningStateKey)
    }
    
    // MARK: Flarm Radius
    class func trafficMonitorRadius()
        -> Double {
            let trafficMonitorRadius = shared.userDefaults.value(forKey: TrafficMonitorRadiusKey) as? Double ?? trafficMonitorRadiusDefault
            return trafficMonitorRadius
    }
    
    class func set(trafficMonitorRadius: Double) {
        shared.userDefaults.set(trafficMonitorRadius, forKey: TrafficMonitorRadiusKey)
    }
    
    // MARK: Centering Help Switch
    class func centeringHelpState()
        -> Bool {
            let centeringHelpSwitch = shared.userDefaults.value(forKey: CenteringHelpStateKey) as? Bool ?? centeringHelpSwitchDefault
            return centeringHelpSwitch
    }
    
    class func set(centeringHelpState: Bool) {
        shared.userDefaults.set(centeringHelpState, forKey: CenteringHelpStateKey)
    }
    
    // MARK: User Map Zoom Level
    class func userMapZoomLevel()
        -> Double {
            let userMapZoomLevel = shared.userDefaults.value(forKey: UserMapZoomLevelKey) as? Double ?? userMapZoomLevelDefault
            return userMapZoomLevel
    }
    
    class func set(userMapZoomLevel: Double) {
        shared.userDefaults.set(userMapZoomLevel, forKey: UserMapZoomLevelKey)
    }
    
    // MARK: Map Country
    class func mapCountry()
        -> String {
            let mapCountry = shared.userDefaults.value(forKey: MapCountryKey) as? String ?? mapCountryDefault
            return mapCountry
    }
    
    class func set(mapCountry: String) {
        shared.userDefaults.set(mapCountry, forKey: MapCountryKey)
    }
    
}
