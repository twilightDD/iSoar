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
    private static let LandingGearWarningSwitchKey = "landingGearWarningSwitch"
    private static let ShowTrackingRouteSwitchKey = "showTrackingRouteSwitch"

    // MARK: - Defaults
    private static let gliderIDDefault = "D-XXXX"
    private static let gliderRadioDefault: Double = 20
    private static let landingGearWarningSwitchDefault: Bool = true
    private static let safetyAltitudeDefault: Double = 200
    private static let showTrackingRouteSwitchDefault: Bool = true
    
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
        if shared.userDefaults.value(forKey: LandingGearWarningSwitchKey) == nil {
            shared.userDefaults.set(true, forKey: LandingGearWarningSwitchKey)
        }
        if shared.userDefaults.value(forKey: ShowTrackingRouteSwitchKey) == nil {
            shared.userDefaults.set(true, forKey: ShowTrackingRouteSwitchKey)
        }
    }

    // MARK: GliderID
    class func getGliderID()
        -> String {
            let gliderID = shared.userDefaults.value(forKey: GliderIDKey) as? String ?? gliderIDDefault
            return gliderID
    }

    class func set(gliderID value: String) {
        shared.userDefaults.set(value, forKey: GliderIDKey)
    }

    // MARK: GliderRatio
    class func getGliderRatio()
        -> Double {
            let gliderRatio = shared.userDefaults.value(forKey: GliderRatioKey) as? Double ?? gliderRadioDefault
            return gliderRatio
    }
    
    class func set(gliderRatio: Double) {
        shared.userDefaults.set(gliderRatio, forKey: GliderRatioKey)
    }

    // MARK: LandingGearWarningSwitch
    class func getLandingGearWarningSwitch()
        -> Bool {
            let landingGearWarningSwitch = shared.userDefaults.value(forKey: LandingGearWarningSwitchKey) as? Bool ?? landingGearWarningSwitchDefault
            return landingGearWarningSwitch
    }
    
    class func set (landingGearWarningSwitch: Bool) {
        shared.userDefaults.set(landingGearWarningSwitch, forKey: LandingGearWarningSwitchKey)
    }

    // MARK: SafetyAltitude
    class func getSafetyAltitude()
        -> Double {
            let safetyAltitude = shared.userDefaults.value(forKey: SafetyAltitudeKey) as? Double ?? safetyAltitudeDefault
            return safetyAltitude
    }

    class func set(safetyAltitude: Double) {
        shared.userDefaults.set(safetyAltitude, forKey: SafetyAltitudeKey)
    }

    // MARK: ShowTrackingRouteSwitch
    class func getShowTrackingRouteSwitchKey()
        -> Bool {
            let showTrackingRouteSwitchKey = shared.userDefaults.value(forKey: ShowTrackingRouteSwitchKey) as? Bool ?? showTrackingRouteSwitchDefault
            return showTrackingRouteSwitchKey
    }
    
    class func set(showTrackingRouteSwitch: Bool) {
        shared.userDefaults.set(showTrackingRouteSwitch, forKey: ShowTrackingRouteSwitchKey)
    }
    
}
