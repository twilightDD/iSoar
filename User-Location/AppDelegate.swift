//
//  AppDelegate.swift
//  User-Location
//
//  Created by Denis Leupold on 8/24/18.
//  Copyright © 2018 Denis Leupold. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Presets.printPresetsWaringsIfNeeded()
        
        // Prevent Display to fall asleep
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Set Screen Brightness to 100%
        UIScreen.main.brightness = CGFloat(1.0)
        
        //Prevent from showing notifications
        UIApplication.shared.unregisterForRemoteNotifications()
        
        // Set up User Defaults
        UserDefaultsManager.setupUserDefaults()

        // Setup Documents/Flights-Folder
        ISoarFileManager.checkForFlightsFolder()
        
        // Setup Documents/Tasks-Folder
        ISoarFileManager.checkForTasksFolder()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        // Set Display Dimmer active again
        UIApplication.shared.isIdleTimerDisabled = false
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Set Display Dimmer active again
        UIApplication.shared.isIdleTimerDisabled = false

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        // Prevent Display to fall asleep
        UIApplication.shared.isIdleTimerDisabled = true
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        // Prevent Display to fall asleep
        UIApplication.shared.isIdleTimerDisabled = true
        
    }

    func applicationWillTerminate(_ application: UIApplication) {

        //Set Display Dimmer active again
        UIApplication.shared.isIdleTimerDisabled = false
        
    }

}
