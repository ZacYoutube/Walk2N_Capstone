//
//  GoalPrediction.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/22/23.
//

import Foundation
import Firebase

public class GoalPredictManager {
    
    static let shared = GoalPredictManager()
    let goalPredictor = goal_predictor()
    let db = DatabaseManager.shared
    
    func predictBasedOnMetrics(completion:@escaping ((Double) -> Void)) {
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if (doc["age"] as? Int) != nil && (doc["weight"] as? Float) != nil && (doc["height"] as? Float) != nil && (doc["gender"] as? String) != nil {
                    var ageLabel: Double = 1.0
                    var genderLabel: Double = 1.0
                    var bmi: Double = 0.0
                    
                    let age = doc["age"] as! Int
                    let weight = doc["weight"] as! Double
                    let height = doc["height"] as! Double
                    let gender = doc["gender"] as! String
                    
                    print(age, weight, height, gender, "in goal predictor")
                    
                    if age < 30 {
                        ageLabel = 0.0
                    }
                    
                    if gender == "Female" {
                        genderLabel = 0.0
                    }
                    
                    let heightToMeter = (height / 100).truncate(places: 0)
                    bmi = (weight / (heightToMeter*heightToMeter)).truncate(places: 0)
                    
                    do {
                        let result = try self.goalPredictor.prediction(gender: genderLabel, age: ageLabel, bmi: bmi)
                        print(result.steps)
                        completion(Double(result.steps))
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    
    func getStepPast7days(completion:@escaping ((Double) -> Void)) {
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["historicalSteps"] != nil && (doc["historicalSteps"] as? [Any]) != nil {
                    var historicalSteps = doc["historicalSteps"] as! [Any]
                    if historicalSteps.count >= 7 {
                        historicalSteps = historicalSteps.sorted(by: {
                            ((($0 as! [String:Any])["date"] as! Timestamp).dateValue()) < ((($1 as! [String:Any])["date"] as! Timestamp).dateValue())
                        })
                        historicalSteps = Array(historicalSteps[historicalSteps.count - 7...historicalSteps.count - 1])
                        var sum: Double = 0.0
                        for i in 0..<historicalSteps.count {
                            let step = historicalSteps[i] as! [String: Any]
                            sum += step["stepCount"] as! Double
                        }
                        let average = (sum / 7).truncate(places: 0)
                        completion(average)
                    }
                    
                } else {
                    completion(0)
                }
            }
        }
    }
    
    func predict() {
        predictBasedOnMetrics { stepsBasedOnMetrics in
            self.getStepPast7days { stepsForPast7Days in
                self.db.updateUserInfo(fieldToUpdate: ["stepGoalToday"], fieldValues: [((stepsBasedOnMetrics + stepsForPast7Days) / 2).truncate(places: 0)]) { bool in }
                print("goal predicted", stepsBasedOnMetrics, stepsForPast7Days)
            }
        }
    }
    
}
