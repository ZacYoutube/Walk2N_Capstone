//
//  AppDelegate.swift
//  Walk2N
//
//  Created by Zhiquan You on 1/30/23.
//

import UIKit
import FirebaseCore
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        scheduleFunctionForMidnight()
        return true
    }

    
    func scheduleFunctionForMidnight() {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.hour = 0
        dateComponents.minute = 0
        
        let timer = Timer(fire: calendar.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime)!, interval: 24 * 60 * 60, repeats: true) { _ in
                // Save data here
                self.addStepToDB()
            }
            
            RunLoop.main.add(timer, forMode: .common)
    }

    private func addStepToDB() {
        if (Auth.auth().currentUser != nil) {
            HealthKitManager().gettingStepCount(0) { stepArr, timeArr in
                for (step, time) in zip(stepArr, timeArr) {
                    let stepGoalToday = 1000.0
                    var reachedGoal = false
                    if step >= stepGoalToday {
                        reachedGoal = true
                    }
                    let stepToday = HistoricalStep(id: UUID().uuidString, uid: Auth.auth().currentUser?.uid, stepCount: Int(step), date: time, reachedGoal: reachedGoal)
                    DatabaseManager.shared.updateArrayData(fieldName: "historicalSteps", fieldVal: stepToday.firestoreData, pop: false) { success in
                        if success == true {
                            print("successfully added")
                        } else {
                            print("unsuccessfully added")
                        }
                    }
                }
            }
        }
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

