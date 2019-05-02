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
        
        //Prevent Display to fall asleep
        UIApplication.shared.isIdleTimerDisabled = true
        
        //Prevent from showing notifications
        UIApplication.shared.unregisterForRemoteNotifications()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        //Set Display Dimmer active again
        UIApplication.shared.isIdleTimerDisabled = false
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        //Prevent Display to fall asleep
        UIApplication.shared.isIdleTimerDisabled = true

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {

        //Set Display Dimmer active again
        UIApplication.shared.isIdleTimerDisabled = false
    }

}

