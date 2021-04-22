//
//  AppDelegate.swift
//  User-Location
//
//  Created by Denis Leupold on 8/24/18.
//  Copyright © 2018 Denis Leupold. All rights reserved.
//

import UIKit
import  CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Presets.printPresetsWaringsIfNeeded()

        // Prevent Display to fall asleep
        UIApplication.shared.isIdleTimerDisabled = true

        // Save User Screen Brightness to UserDefaults
        UserDefaultsManager.set(screenBrightness: UIScreen.main.brightness)

        // Set Screen Brightness to 100%
        UIScreen.main.brightness = CGFloat(1.0)

        // Set up User Defaults
        UserDefaultsManager.setupUserDefaults()

        // Check for First Launch of App
        if UserDefaultsManager.firstLaunchOfAppState() == true {
            CoreDataImporter.initalImport()
            UserDefaultsManager.set(firstLaunchOfAppState: false)
        }

        // Setup Flights, Tasks and Log Folder in Documents
        ISoarFileManager.checkForFlightsFolder()
        ISoarFileManager.checkForTasksFolder()
        ISoarFileManager.checkForLogsFolder()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

        // Screen Brightness back to Users original Setting
        UIScreen.main.brightness = UserDefaultsManager.screenBrightness()

        // Set Display Dimmer active again
        UIApplication.shared.isIdleTimerDisabled = false

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

        // Screen Brightness back to Users original Setting
        UIScreen.main.brightness = UserDefaultsManager.screenBrightness()

        // Set Display Dimmer active again
        UIApplication.shared.isIdleTimerDisabled = false

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

        // Set Screen Brightness to 100%
        UIScreen.main.brightness = CGFloat(1.0)

        // Prevent Display to fall asleep
        UIApplication.shared.isIdleTimerDisabled = true

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

        // Set Screen Brightness to 100%
        UIScreen.main.brightness = CGFloat(1.0)

        // Prevent Display to fall asleep
        UIApplication.shared.isIdleTimerDisabled = true

    }

    func applicationWillTerminate(_ application: UIApplication) {

        // Screen Brightness back to Users original Setting
        UIScreen.main.brightness = UserDefaultsManager.screenBrightness()

        //Set Display Dimmer active again
        UIApplication.shared.isIdleTimerDisabled = false

    }

}
