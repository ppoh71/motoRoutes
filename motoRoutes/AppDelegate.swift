//
//  AppDelegate.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 20.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import RealmSwift
import Fabric
import Crashlytics
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
        FIRApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        print("oldschema \(Realm.Configuration.defaultConfiguration)")
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 6,
            migrationBlock: { migration, oldSchemaVersion in
                
                
                if (oldSchemaVersion < 6) {
                    // The enumerate(_:_:) method iterates
                    migration.enumerateObjects(ofType: Location.className()) { oldObject, newObject in
                        newObject!["distance"] = 0.0
                    }
                    
                    migration.enumerateObjects(ofType: Route.className()) { oldObject, newObject in
                        newObject!["locationStart"] = "Start Location"
                        newObject!["locationEnd"] = "End Location"
                    }
                    
                    migration.enumerateObjects(ofType: Route.className()) { oldObject, newObject in
                        newObject!["startLatitude"] = 0.0
                        newObject!["startLongitude"] = 0.0
                    }
                }
        })
    
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }


    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
}

