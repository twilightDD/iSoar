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
    private static let GliderRatioKey = "gliderRatio"
    private static let SafetyAltitudeKey = "safetyAltitude"
    private static let GliderIDKey = "gliderID"
    private static let GearWarningSwitchKey = "gearWarningSwitch"
    private static let ShowTrackingRouteSwitchKey = "showTrackingRouteSwitch"
    private static let ShowFlarmBuddySwitchKey = "showFlarmBuddySwitch"
    private static let BuddyFlarmIDKey = "buddyFlarmID"
    private static let ShowNearbyGlidersSwitchKey = "showNearbyGlidersSwitch"
    private static let CollisionWarningSwitchKey = "collisionWarningSwitch"
    
    // MARK: - Defaults
    private static let gliderIDDefault = "D-XXXX"
    private static let gliderRadioDefault: Double = 20
    private static let gearWarningSwitchDefault: Bool = true
    private static let safetyAltitudeDefault: Double = 200
    private static let showTrackingRouteSwitchDefault: Bool = true
    private static let showFlarmBuddySwitchDefault: Bool = true
    private static let buddyFlarmIDDefault = "FLRDxxxxx"
    private static let showNearbyGlidersSwitchDefault: Bool = true
    private static let collisionWarningSwitchDefault: Bool = true
    
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
        if shared.userDefaults.value(forKey: GearWarningSwitchKey) == nil {
            shared.userDefaults.set(true, forKey: GearWarningSwitchKey)
        }
        if shared.userDefaults.value(forKey: ShowTrackingRouteSwitchKey) == nil {
            shared.userDefaults.set(true, forKey: ShowTrackingRouteSwitchKey)
        }
        if shared.userDefaults.value(forKey: ShowFlarmBuddySwitchKey) == nil {
            shared.userDefaults.set(true, forKey: ShowFlarmBuddySwitchKey)
        }
        if shared.userDefaults.value(forKey: BuddyFlarmIDKey) == nil {
            UserDefaultsManager.set(flarmBuddyFlarmID: buddyFlarmIDDefault)
        }
        if shared.userDefaults.value(forKey: ShowNearbyGlidersSwitchKey) == nil {
            shared.userDefaults.set(true, forKey: ShowNearbyGlidersSwitchKey)
        }
        if shared.userDefaults.value(forKey: CollisionWarningSwitchKey) == nil {
            shared.userDefaults.set(true, forKey: CollisionWarningSwitchKey)
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
            let gearWarningSwitch = shared.userDefaults.value(forKey: GearWarningSwitchKey) as? Bool ?? gearWarningSwitchDefault
            return gearWarningSwitch
    }
    
    class func set(gearWarningState: Bool) {
        shared.userDefaults.set(gearWarningState, forKey: GearWarningSwitchKey)
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
            let showTrackingRouteSwitchKey = shared.userDefaults.value(forKey: ShowTrackingRouteSwitchKey) as? Bool ?? showTrackingRouteSwitchDefault
            return showTrackingRouteSwitchKey
    }
    
    class func set(showTrackingRouteState: Bool) {
        shared.userDefaults.set(showTrackingRouteState, forKey: ShowTrackingRouteSwitchKey)
    }
    
    // MARK: ShowFlarmBuddySwitch
    class func showOnlyFlarmBuddyNearbyGliderState()
        -> Bool {
            let showFlarmBuddySwitchKey = shared.userDefaults.value(forKey: ShowFlarmBuddySwitchKey) as? Bool ?? showFlarmBuddySwitchDefault
            return showFlarmBuddySwitchKey
    }
    
    class func set(showOnlyFlarmBuddyNearbyGliderState: Bool) {
        shared.userDefaults.set(showOnlyFlarmBuddyNearbyGliderState, forKey: ShowFlarmBuddySwitchKey)
    }
    
    // MARK: Buddy FlarmID
    class func flarmBuddyFlarmID()
        -> String {
            let buddyFlarmID = shared.userDefaults.value(forKey: BuddyFlarmIDKey) as? String ?? buddyFlarmIDDefault
            return buddyFlarmID
    }
    
    class func set(flarmBuddyFlarmID flarmID: String) {
        shared.userDefaults.set(flarmID, forKey: BuddyFlarmIDKey)
    }
    
    // MARK: ShowNearbyGlidersSwitch
    class func showAllNearbyGlidersState()
        -> Bool {
            let showNearbyGlidersSwitch = shared.userDefaults.value(forKey: ShowNearbyGlidersSwitchKey) as? Bool ?? showNearbyGlidersSwitchDefault
            return showNearbyGlidersSwitch
    }
    
    class func set(showAllNearbyGlidersState: Bool) {
        shared.userDefaults.set(showAllNearbyGlidersState, forKey: ShowNearbyGlidersSwitchKey)
    }
    
    // MARK: CollisionWarningSwitch
    class func collisionWarningState()
        -> Bool {
            let collisionWarningSwitch = shared.userDefaults.value(forKey: CollisionWarningSwitchKey) as? Bool ?? collisionWarningSwitchDefault
            return collisionWarningSwitch
    }
    
    class func set(collisionWarningState: Bool) {
        shared.userDefaults.set(collisionWarningState, forKey: CollisionWarningSwitchKey)
    }

}
