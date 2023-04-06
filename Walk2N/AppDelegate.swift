//
//  AppDelegate.swift
//  Walk2N
//
//  Created by Zhiquan You on 1/30/23.
//

import UIKit
import FirebaseCore
import Firebase
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            // Handle the user's response to the permission request.
            if granted {
                print("user granted notification")
            }
            if (error != nil) {
                print("error occurred \(String(describing: error))")
            }
        }
        UNUserNotificationCenter.current().delegate = self
        
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
    
    // Handle local notifications when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Execute your function here
        let content = notification.request.content
        let body = content.body
        
        let alertObj = Alert(message: body, date: Date())
        
        print("alert received in will present")
        
        DatabaseManager.shared.updateArrayData(fieldName: "alertHist", fieldVal: alertObj.firestoreData, pop: false) { bool in }
        
        completionHandler([.alert, .sound, .badge])
    }
    
    // Handle local notifications when app is in background or not running
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Execute your function here
        let content = response.notification.request.content
        let body = content.body
        
        print("alert received in did receive")
        
        let alertObj = Alert(message: body, date: Date())
        DatabaseManager.shared.updateArrayData(fieldName: "alertHist", fieldVal: alertObj.firestoreData, pop: false) { bool in }
        
        completionHandler()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("didbecomeactive triggered")
        let currentDate = Date()
        let userDefaults = UserDefaults.standard
        
        if let lastDate = userDefaults.object(forKey: "lastDate") as? Date {
            let calendar = Calendar.current
            //            let components = calendar.dateComponents([.day], from: lastDate, to: currentDate)
            //            if let days = components.day, days >= 1 {
            if UpdateManager().isSameDay(currentDate, lastDate) == false {
                GoalPredictManager.shared.predict()
                userDefaults.set(currentDate, forKey: "lastDate")
            }
        } else {
            userDefaults.set(currentDate, forKey: "lastDate")
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.synchronize()
    }
    
    
}

