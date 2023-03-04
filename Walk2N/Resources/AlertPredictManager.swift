//
//  AlertPredictManager.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/22/23.
//

import Foundation
import UserNotifications

class AlertPredictManager {
    
    static let shared = AlertPredictManager()
    let db = DatabaseManager.shared
    
    let alertPredictor = alert_predictor()
    
    let dispatchGroup = DispatchGroup()
    
    func getStepCountFor3Intervals(completion:@escaping (([Double]) -> Void)) {
        let calendar = Calendar.current
        let date0am = calendar.startOfDay(for: Date())
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        let date6am = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: calendar.date(from: components)!)!
        let date12pm = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: calendar.date(from: components)!)!
        let date4pm = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: calendar.date(from: components)!)!
        
        let timeIntervals = [[date0am, date6am], [date6am, date12pm], [date12pm, date4pm]]
        var resultArr: [Double] = []
        
        for i in 0..<timeIntervals.count {
            dispatchGroup.enter()
            let startDate = timeIntervals[i][0]
            let endDate = timeIntervals[i][1]
            HealthKitManager().getStepCountBetweenTimestamps(startDate: startDate, endDate: endDate) { steps, err in
                resultArr.append(steps)
                self.dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(resultArr)
            }
        }
    }
    
    func predictAndSetupNotification() {
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["stepGoalToday"] != nil && (doc["stepGoalToday"] as? Double) != nil {
                    let stepGoalToday = doc["stepGoalToday"] as! Double
                    self.getStepCountFor3Intervals { stepsArr in
                        if stepsArr.count >= 3 {
                            do {
                                let result = try self.alertPredictor.prediction(sum_steps_0_to_6: stepsArr[0] != nil ? stepsArr[0] : 0, sum_steps_6_to_12: stepsArr[1] != nil ? stepsArr[1] : 0, sum_steps_12_to_16: stepsArr[2] != nil ? stepsArr[2] : 0, step_goal: stepGoalToday)
                                let stepCountSoFar = stepsArr[0] + stepsArr[1] + stepsArr[2]
                                _ = UNUserNotificationCenter.current()
                                let content = UNMutableNotificationContent()
                                content.title = "Walk2N"
                                
                                if result.goal_reached == "True" {
                                    content.body = "Doing well so far, keep walking!"
                                } else if result.goal_reached == "False" {
                                    content.body = "Stand up and walk more, \(stepGoalToday - stepCountSoFar) steps to go!"
                                }
                                content.sound = UNNotificationSound.default
                                content.badge = 1
                                
                                let dateComponents = DateComponents(hour: 16, minute: 00) // Set the hour and minute to schedule the notification for.
                                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                                let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: trigger)
                                
                                UNUserNotificationCenter.current().add(request) { error in
                                    if let error = error {
                                        print("error occurred \(error.localizedDescription)")
                                    } else {
                                        print("notified successfully")
                                    }
                                }
                                
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}
