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
    private static let BuddyFlarmIDKey = "buddyFlarmID"
    private static let GliderRatioKey = "gliderRatio"
    private static let GliderIDKey = "gliderID"
    private static let OwnFlarmIDKey = "ownFlarmID"
    private static let GearWarningStateKey = "gearWarningState"
    private static let SafetyAltitudeKey = "safetyAltitude"
    private static let ShowAllNearbyGlidersStateKey = "showAllNearbyGlidersState"
    private static let ShowOnlyBuddyStateKey = "showOnlyBuddyState"
    private static let ShowTrackingRouteStateKey = "showTrackingRouteState"
    private static let FlarmRadiusKey = "flarmRadius"
    private static let CenteringHelpStateKey = "centeringHelpState"
    
    // MARK: - Defaults
    private static let gliderIDDefault = "D-XXXX"
    private static let ownFlarmIDDefault = "FLRxxxxxx"
    private static let gliderRadioDefault: Double = 20
    private static let gearWarningSwitchDefault: Bool = true
    private static let safetyAltitudeDefault: Double = 200
    private static let showTrackingRouteSwitchDefault: Bool = true
    private static let showFlarmBuddySwitchDefault: Bool = true
    private static let buddyFlarmIDDefault = "FLRxxxxxx"
    private static let showNearbyGlidersSwitchDefault: Bool = true
    private static let collisionWarningSwitchDefault: Bool = true
    private static let flarmRadiusDefault: Double = 25
    private static let centeringHelpSwitchDefault: Bool = true
    
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
        if shared.userDefaults.value(forKey: BuddyFlarmIDKey) == nil {
            UserDefaultsManager.set(flarmBuddyFlarmID: buddyFlarmIDDefault)
        }
        if shared.userDefaults.value(forKey: ShowAllNearbyGlidersStateKey) == nil {
            shared.userDefaults.set(true, forKey: ShowAllNearbyGlidersStateKey)
        }
        if shared.userDefaults.value(forKey: CollisionWarningStateKey) == nil {
            shared.userDefaults.set(true, forKey: CollisionWarningStateKey)
        }
        if shared.userDefaults.value(forKey: FlarmRadiusKey) == nil {
            UserDefaultsManager.set(flarmRadius: flarmRadiusDefault)
        }
        if shared.userDefaults.value(forKey: CenteringHelpStateKey) == nil {
            shared.userDefaults.set(true, forKey: CenteringHelpStateKey)
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
    
    // MARK: Buddy FlarmID
    class func buddyFlarmID()
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
    class func flarmRadius()
        -> Double {
            let flarmRadius = shared.userDefaults.value(forKey: FlarmRadiusKey) as? Double ?? flarmRadiusDefault
            return flarmRadius
    }
    
    class func set(flarmRadius: Double) {
        shared.userDefaults.set(flarmRadius, forKey: FlarmRadiusKey)
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
    
}
