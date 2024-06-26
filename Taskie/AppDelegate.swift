//
//  AppDelegate.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseFunctions

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        LogUtil.log("App launched with options: \(String(describing: launchOptions))")
        // umcomment this to hit emulators
        //        // firestore
        //        let settings = Firestore.firestore().settings
        //        settings.host = "localhost:8080"
        //        settings.isSSLEnabled = false
        //        Firestore.firestore().settings = settings
        //        // Authentication
        //        Auth.auth().useEmulator(withHost: "localhost", port: 9099)
        //        // Storage
        //        let storage = Storage.storage()
        //        storage.useEmulator(withHost: "localhost", port: 9199)
        //        // Functions
        //        let functions = Functions.functions()
        //        functions.useEmulator(withHost: "localhost", port: 5001)
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

