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
        
        // Saves changes in the application's managed object context
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Glider Tool")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

