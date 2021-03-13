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
    private static let LowOxygenWarningStateKey = "LowOxygenWarningState"
    private static let SafetyAltitudeKey = "safetyAltitude"
    private static let ShowAllNearbyGlidersStateKey = "showAllNearbyGlidersState"
    private static let BuddyFilterStateKey = "buddyFilterState"
    private static let ShowTrackingRouteStateKey = "showTrackingRouteState"
    private static let TrafficMonitorRadiusKey = "trafficMonitorRadius"
    private static let ThermalAssistantStateKey = "thermalAssistantState"
    private static let UserMapZoomLevelKey = "userMapZoomLevel"
    private static let SelectedCountryKey = "mapCountry"
    private static let MapStyleURLKey = "mapStyleURL"
    private static let ShowDistanceCirclesStateKey = "showDistanceCirclesStateKey"
    private static let FirstLaunchOfAppStateKey = "firstLaunchOfAppStateKey"
    private static let ShowFightSummaryStateKey = "showFightSummaryState"
    
    // MARK: - Defaults
    private static let gliderIDDefault = "D-XXXX"
    private static let ownFlarmIDDefault = "FLRxxxxxx"
    private static let gliderRadioDefault: Double = 30
    private static let gearWarningSwitchDefault: Bool = false
    private static let lowOxygenWarningSwitchDefault: Bool = false
    private static let safetyAltitudeDefault: Double = 300
    private static let showTrackingRouteSwitchDefault: Bool = true
    private static let showFlarmBuddySwitchDefault: Bool = false
    private static let showNearbyGlidersSwitchDefault: Bool = true
    private static let collisionWarningSwitchDefault: Bool = false
    private static let trafficMonitorRadiusDefault: Double = 50
    private static let thermalAssistantSwitchDefault: Bool = true
    private static let userMapZoomLevelDefault: Double = 9.6
    private static let selectedCountryDefault: String = "Germany"
    private static let mapStyleURLDefault: String = "mapbox://styles/dlmapbox/cka5rqao21e0z1iqisptn1fwt"
    private static let showDistanceCirclesSwitchDefault: Bool = false
    private static let firstLaunchOfAppDefault: Bool = true
    private static let showFlightSummaryDefault: Bool = false
    
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
            shared.userDefaults.set(false, forKey: GearWarningStateKey)
        }
        if shared.userDefaults.value(forKey: LowOxygenWarningStateKey) == nil {
            shared.userDefaults.set(false, forKey: LowOxygenWarningStateKey)
        }
        if shared.userDefaults.value(forKey: ShowTrackingRouteStateKey) == nil {
            shared.userDefaults.set(true, forKey: ShowTrackingRouteStateKey)
        }
        if shared.userDefaults.value(forKey: BuddyFilterStateKey) == nil {
            shared.userDefaults.set(false, forKey: BuddyFilterStateKey)
        }
        if shared.userDefaults.value(forKey: ShowAllNearbyGlidersStateKey) == nil {
            shared.userDefaults.set(true, forKey: ShowAllNearbyGlidersStateKey)
        }
        if shared.userDefaults.value(forKey: CollisionWarningStateKey) == nil {
            shared.userDefaults.set(false, forKey: CollisionWarningStateKey)
        }
        if shared.userDefaults.value(forKey: TrafficMonitorRadiusKey) == nil {
            UserDefaultsManager.set(trafficMonitorRadius: trafficMonitorRadiusDefault)
        }
        if shared.userDefaults.value(forKey: ThermalAssistantStateKey) == nil {
            shared.userDefaults.set(true, forKey: ThermalAssistantStateKey)
        }
        if shared.userDefaults.value(forKey: UserMapZoomLevelKey) == nil {
            UserDefaultsManager.set(userMapZoomLevel: userMapZoomLevelDefault)
        }
        if shared.userDefaults.value(forKey: SelectedCountryKey) == nil {
            UserDefaultsManager.set(mapCountry: selectedCountryDefault)
        }
        if shared.userDefaults.value(forKey: MapStyleURLKey) == nil {
            UserDefaultsManager.set(mapStyleURL: mapStyleURLDefault)
        }
        if shared.userDefaults.value(forKey: ShowDistanceCirclesStateKey) == nil {
            shared.userDefaults.set(false, forKey: ShowDistanceCirclesStateKey)
        }
        if shared.userDefaults.value(forKey: FirstLaunchOfAppStateKey) == nil {
            shared.userDefaults.set(true, forKey: FirstLaunchOfAppStateKey)
        }
        if shared.userDefaults.value(forKey: ShowFightSummaryStateKey) == nil {
            shared.userDefaults.set(false, forKey: ShowFightSummaryStateKey)
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
    
    // MARK: LowOxygenWarningSwitch
    class func lowOxygenWarningState()
    -> Bool {
        let lowOxygenWarningSwitch = shared.userDefaults.value(forKey: LowOxygenWarningStateKey) as? Bool ?? lowOxygenWarningSwitchDefault
        return lowOxygenWarningSwitch
    }
    
    class func set(lowOxygenWarningState: Bool) {
        shared.userDefaults.set(lowOxygenWarningState, forKey: LowOxygenWarningStateKey)
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
    class func buddyFilterSwitchState()
    -> Bool {
        let buddyFilterSwitchKey = shared.userDefaults.value(forKey: BuddyFilterStateKey) as? Bool ?? showFlarmBuddySwitchDefault
        return buddyFilterSwitchKey
    }
    
    class func set(buddyFilterSwitchState: Bool) {
        shared.userDefaults.set(buddyFilterSwitchState, forKey: BuddyFilterStateKey)
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
    
    // MARK: Thermal Assistant Switch
    class func thermalAssistantState()
    -> Bool {
        let thermalAssistantSwitch = shared.userDefaults.value(forKey: ThermalAssistantStateKey) as? Bool ?? thermalAssistantSwitchDefault
        return thermalAssistantSwitch
    }
    
    class func set(thermalAssistantState: Bool) {
        shared.userDefaults.set(thermalAssistantState, forKey: ThermalAssistantStateKey)
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
    class func selectedCountry()
    -> String {
        let selectedCountry = shared.userDefaults.value(forKey: SelectedCountryKey) as? String ?? selectedCountryDefault
        return selectedCountry
    }
    
    class func set(mapCountry: String) {
        shared.userDefaults.set(mapCountry, forKey: SelectedCountryKey)
    }
    
    // MARK: Map Style URL
    class func mapStyleURL()
    -> String {
        let mapStyleURL = shared.userDefaults.value(forKey: MapStyleURLKey) as? String ?? mapStyleURLDefault
        return mapStyleURL
    }
    
    class func set(mapStyleURL: String) {
        shared.userDefaults.set(mapStyleURL, forKey: MapStyleURLKey)
    }
    
    // MARK: Show Distance Circles Switch
    class func showDistanceCirclesState()
    -> Bool {
        let showDistanceCirclesSwitchKey = shared.userDefaults.value(forKey: ShowDistanceCirclesStateKey) as? Bool ?? showDistanceCirclesSwitchDefault
        return showDistanceCirclesSwitchKey
    }
    
    class func set(showDistanceCirclesState: Bool) {
        shared.userDefaults.set(showDistanceCirclesState, forKey: ShowDistanceCirclesStateKey)
    }
    
    // MARK: First Launch of the App
    class func firstLaunchOfAppState()
    -> Bool {
        let firstLaunchOfAppKey = shared.userDefaults.value(forKey: FirstLaunchOfAppStateKey) as? Bool ?? firstLaunchOfAppDefault
        return firstLaunchOfAppKey
    }
    
    class func set(firstLaunchOfAppState: Bool) {
        shared.userDefaults.set(firstLaunchOfAppState, forKey: FirstLaunchOfAppStateKey)
    }
    
    // MARK: Show Flight Summary Switch
    class func showFlightSummaryState()
    -> Bool {
        let showFlightSummarySwitch = shared.userDefaults.value(forKey: ShowFightSummaryStateKey) as? Bool ?? showFlightSummaryDefault
        return showFlightSummarySwitch
    }
    
    class func set(showFlightSummaryState: Bool) {
        shared.userDefaults.set(showFlightSummaryState, forKey: ShowFightSummaryStateKey)
    }
    
}
