//
//  UpdateManager.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/26/23.
//

import Foundation
import Firebase

class UpdateManager {
    
    func updateBonusAndHistoricalSteps() {
        let db = DatabaseManager.shared
        
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["historicalSteps"] != nil && (doc["historicalSteps"] as? [Any]) != nil {
                    var historicalSteps = doc["historicalSteps"] as! [Any]
                    
                    // sort the array by its date so that we can get the latest, newest step data in the collection
                    historicalSteps = historicalSteps.sorted(by: {
                        ((($0 as! [String:Any])["date"] as! Timestamp).dateValue()) < ((($1 as! [String:Any])["date"] as! Timestamp).dateValue())
                    })
                    
                    let newestStepData = historicalSteps[historicalSteps.count - 1] as! [String: Any]
                    let newestSteps = newestStepData["stepCount"] as! Double
                    
                    let newestStepDate = (newestStepData["date"] as! Timestamp).dateValue()
                    let today = Date()
                    let diffInDays = Calendar.current.dateComponents([.day], from: newestStepDate, to: today).day!
                    
                    let wearShoe = newestStepData["wearShoe"] as! Bool
                    let reachedGoal = newestStepData["reachedGoal"] as! Bool
                    
                    let balance = doc["balance"] as! Double
                    var bonusSoFar = doc["bonusEarnedToday"] as! Double
                    // this is the bonus calculated from the map section
                    let bonusEarnedDuringRealTimeRun = doc["bonusEarnedDuringRealTimeRun"] as! Double
                    
                    var awardPerStep: Double? = 0.0
                    if doc["currentShoe"] as? [String: Any] != nil {
                        let currentShoe = doc["currentShoe"] as! [String: Any]
                        awardPerStep = (currentShoe["awardPerStep"] as! Double)
                    }
                    var bonusEarned = 0.0
                    var newEarning = balance
                    
                    // if user has not been rewarded for reaching step goal, we reward him/her and update the corresponding field
                    if doc["bonusAwardedForReachingStepGoal"] as! Bool == false &&  reachedGoal == true {
                        bonusSoFar += 100.0
                        db.updateUserInfo(fieldToUpdate: ["bonusAwardedForReachingStepGoal", "bonusEarnedToday", "balance"], fieldValues: [true, bonusSoFar, balance + bonusSoFar]) { bool in }
                    }
                    
                    HealthKitManager().gettingStepCount(0) { [self] steps, time in
                        if steps.count > 0 {
                            let currentStep = steps[0]
                            
                            if wearShoe == true && newestSteps < currentStep {
                                
                                // do the formula here:
                                bonusEarned = (currentStep - newestSteps) * awardPerStep!
                                // need to delete duplicate earning from map run
                                newEarning = balance + bonusEarned - bonusEarnedDuringRealTimeRun
                                print(bonusEarned, newEarning, bonusSoFar)
                                db.updateUserInfo(fieldToUpdate: ["balance"], fieldValues: [newEarning]) { bool in }
                                db.updateUserInfo(fieldToUpdate: ["bonusEarnedToday"], fieldValues: [bonusSoFar + bonusEarned - bonusEarnedDuringRealTimeRun]) { bool in }
                                db.updateUserInfo(fieldToUpdate: ["bonusEarnedDuringRealTimeRun"], fieldValues: [0]) { bool in }
                            }
                            
                            let b = doc["bonusEarnedToday"] as? Double ?? 0
                            
                            // if there is step data in the database check if these are up to date, and push the most recent data into the db
                            if diffInDays > 0 {
                                self.addStepToDB(diffInDays - 1, bonus: b)
                                GoalPredictManager.shared.predict()
                                if steps[0] == 0.0 {
                                    db.updateUserInfo(fieldToUpdate: ["bonusEarnedToday"], fieldValues: [0]) { bool in }
                                } else {
                                    if wearShoe == true {
                                        db.updateUserInfo(fieldToUpdate: ["bonusEarnedToday"], fieldValues: [steps[0] * awardPerStep!]) { bool in }
                                    }
                                }
                            } else {
                                // if it is the same day, check if steps are the same, if not, update the same day step count
                                if newestSteps < currentStep {
                                    var newestHistoricalArray = [] // update the array
                                    for i in 0..<historicalSteps.count {
                                        if (historicalSteps[i] as! [String: Any])["id"] as! String == newestStepData["id"] as! String {
                                            let elem = historicalSteps[i] as! [String: Any]
                                            let reachedGoal = currentStep >= ((doc["stepGoalToday"] as? Double) != nil ? doc["stepGoalToday"] as! Double : 0.0)
                                            let wearShoe = doc["currentShoe"] as? [String: Any]? == nil ? false: true
                                            let newElem = HistoricalStep(id: (elem["id"] as! String), uid: (elem["uid"] as! String), stepCount: Int(currentStep), date: (elem["date"] as! Timestamp).dateValue(), reachedGoal: reachedGoal, wearShoe: wearShoe, stepGoal: (doc["stepGoalToday"] as? Double ?? 0.0), bonusEarned: doc["bonusEarnedToday"] as? Double ?? 0.0)
                                            newestHistoricalArray.append(newElem.firestoreData)
                                        } else {
                                            newestHistoricalArray.append(historicalSteps[i])
                                        }
                                    }
                                    db.updateUserInfo(fieldToUpdate: ["historicalSteps"], fieldValues: [newestHistoricalArray]) { bool in }
                                }
                            }
                        }
                        // meaning no data is recorded yet
                        else {
                            let lastDay = ((historicalSteps[historicalSteps.count - 1] as! [String: Any])["date"] as! Timestamp).dateValue()
                            let today = Date()
                            if self.isSameDay(lastDay, today) == false {
                                // reset everything
                                let wearShoe = (doc["currentShoe"] as? [String: Any]) != nil ? true : false
                                let stepToday = HistoricalStep(id: UUID().uuidString, uid: Auth.auth().currentUser?.uid, stepCount: Int(0), date: Date(), reachedGoal: false, wearShoe: wearShoe, stepGoal: (doc["stepGoalToday"] as! Double), bonusEarned: doc["bonusEarned"] as? Double ?? 0.0)
                                self.updateDBWithStep(stepData: stepToday)
                                db.updateUserInfo(fieldToUpdate: ["bonusEarnedToday", "bonusEarnedDuringRealTimeRun", "bonusAwardedForReachingStepGoal"], fieldValues: [0, 0, false]) { bool in }
                                GoalPredictManager.shared.predict()
                            }
                          }
                        }
                    
                    
                    
                    
                }
                else {
                    self.addStepToDB(6, bonus: 0)
                }
                
            }
        }
    }
    
    func checkWhetherBonusIsCalculated(historyArr: [Any], date: Date) -> Bool {
        for i in 0..<historyArr.count {
            let bonus = historyArr[i] as! [String: Any]
            let bonusDate = (bonus["date"] as! Timestamp).dateValue()
            
            if isSameDay(bonusDate, date){
                return true
            }
        }
        return false
    }
    
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        return components1.year == components2.year &&
        components1.month == components2.month &&
        components1.day == components2.day
    }
    
    //    func updateHistoricalSteps() {
    //        let db = DatabaseManager.shared
    //
    //        db.getUserInfo { docSnapshot in
    //            for doc in docSnapshot {
    //                // check whether there's historical step data available, if not, push the past week's step data
    //                if doc["historicalSteps"] != nil {
    //                    var historicalSteps = doc["historicalSteps"] as! [Any]
    //                    historicalSteps = historicalSteps.sorted(by: {
    //                        ((($0 as! [String:Any])["date"] as! Timestamp).dateValue()) < ((($1 as! [String:Any])["date"] as! Timestamp).dateValue())
    //                    })
    //                    let newestStep = historicalSteps[historicalSteps.count - 1] as! [String: Any]
    //                    let newestStepDate = (newestStep["date"] as! Timestamp).dateValue()
    //                    let today = Date()
    //                    let diffInDays = Calendar.current.dateComponents([.day], from: newestStepDate, to: today).day!
    //
    //                    // if there is step data in the database check if these are up to date, and push the most recent data into the db
    //                    if diffInDays > 0 {
    //                        self.addStepToDB(diffInDays - 1)
    //                    } else {
    //                        // if it is the same day, check if steps are the same, if not, update the same day step count
    //                        HealthKitManager().gettingStepCount(0) { stepArr, timeArr in
    //                            if stepArr.count > 0 {
    //                                let stepToday = stepArr[0]
    //                                let stepCount = newestStep["stepCount"] as! Double
    //
    //                                if stepToday != stepCount {
    //                                    var newestHistoricalArray = []
    //                                    for i in 0..<historicalSteps.count {
    //                                        if (historicalSteps[i] as! [String: Any])["id"] as! String == newestStep["id"] as! String {
    //                                            let elem = historicalSteps[i] as! [String: Any]
    //                                            let reachedGoal = stepToday >= 1000
    //                                            let wearShoe = doc["currentShoe"] as? [String: Any]? == nil ? false: true
    //                                            let newElem = HistoricalStep(id: (elem["id"] as! String), uid: (elem["uid"] as! String), stepCount: Int(stepToday), date: (elem["date"] as! Timestamp).dateValue(), reachedGoal: reachedGoal, wearShoe: wearShoe, stepGoal: (elem["stepGoal"] as! Double))
    //                                            newestHistoricalArray.append(newElem.firestoreData)
    //                                        } else {
    //                                            newestHistoricalArray.append(historicalSteps[i])
    //                                        }
    //                                    }
    //                                    db.updateUserInfo(fieldToUpdate: ["historicalSteps"], fieldValues: [newestHistoricalArray]) { bool in }
    //                                }
    //                            }
    //                        }
    //                    }
    //                }
    //                else {
    //                    self.addStepToDB(6)
    //                }
    //            }
    //        }
    //    }
    
    private func addStepToDB(_ n: Int, bonus: Double) {
        if (Auth.auth().currentUser != nil) {
            DatabaseManager().updateUserInfo(fieldToUpdate: ["bonusEarnedDuringRealTimeRun", "bonusAwardedForReachingStepGoal"], fieldValues: [0, false]) { bool in }
            var count = 0
            HealthKitManager().gettingStepCount(n) { stepArr, timeArr in
                count += 1
                for (step, time) in zip(stepArr, timeArr) {
                    var reachedGoal = false
                    var stepGoalToday = 0.0
                    
                    var stepToday: HistoricalStep?
                    DatabaseManager.shared.getUserInfo { docSnapshot in
                        for doc in docSnapshot {
                            if doc["stepGoalToday"] != nil && (doc["stepGoalToday"] as? Double) != nil {
                                stepGoalToday = doc["stepGoalToday"] as! Double
                                if step >= stepGoalToday {
                                    reachedGoal = true
                                }
                            }
                        
                            if n > 1 && self.isSameDay(time, Date()) == false {
                                stepGoalToday = 0
                            }
                            
                            if doc["currentShoe"] as? [String: Any] != nil {
                                stepToday = HistoricalStep(id: UUID().uuidString, uid: Auth.auth().currentUser?.uid, stepCount: Int(step), date: time, reachedGoal: reachedGoal, wearShoe: true, stepGoal: stepGoalToday, bonusEarned: bonus)
                                self.updateDBWithStep(stepData: stepToday!)
                            } else {
                                stepToday = HistoricalStep(id: UUID().uuidString, uid: Auth.auth().currentUser?.uid, stepCount: Int(step), date: time, reachedGoal: reachedGoal, wearShoe: false, stepGoal: stepGoalToday, bonusEarned: bonus)
                                self.updateDBWithStep(stepData: stepToday!)
                            }
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    private func updateDBWithStep(stepData: HistoricalStep) {
        DatabaseManager.shared.updateArrayData(fieldName: "historicalSteps", fieldVal: stepData.firestoreData, pop: false) { success in
            if success == true {
                print("successfully added")
            } else {
                print("unsuccessfully added")
            }
        }
    }
}
