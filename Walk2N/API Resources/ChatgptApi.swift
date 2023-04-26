//
//  GptApi.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/3/23.
//

import Foundation
import ChatGPTSwift
import Firebase

struct Model: Codable {
    var date: String
    var steps: Double?
    var activeEnergy: Double?
    var exerciseMinutes: Double?
    var heartRate: Double?
    var distance: Double?
}

class GptApiService {
    private let apiKey = ApiKeyObject.apiKey
    var mainPrompt = "As a knowledgeable and passionate caregiver with expertise in personal health, you are being asked to provide brief responses that address the user's queries, while avoiding the use of statistical data. If any health metric appears to be low, kindly offer advice on how the user can improve. Some health metrics over the past two weeks (14 days) to incorporate is given below. If a value is zero, the user has not inputted anything for that day. Do NOT say the metric is zero. For example, if heart rate is zero on one day, it simply means user has not recorded his/her heart rate. \n\n"
    let db = DatabaseManager.shared
    
    func getGptResponse(messagePrompt: String, completion:((String) -> Void)?) {
        let api = ChatGPTAPI(apiKey: apiKey)
        let dispatchGroup = DispatchGroup()
        Task {
            do {
                var model: [Model] = []
                let cal = Calendar.current
                let today = Date()
                
                for day in 1...14 {
                    guard let endDate = cal.date(byAdding: .day, value: -day, to: today) else { continue }
                    model.append(Model(date: DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .none)))
                }
                
                dispatchGroup.enter()
                HealthKitManager().gettingLastFewWeeksStepCount { steps in
                    for i in 0...13 {
                        model[i].steps = steps[i]
                    }
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                HealthKitManager().gettingLastFewWeeksActiveEnergy { energies in
                    for i in 0...13 {
                        model[i].activeEnergy = energies[i]
                    }
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                HealthKitManager().gettingLastFewWeeksExerciseTime { exercises in
                    for i in 0...13 {
                        model[i].exerciseMinutes = exercises[i]
                    }
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                HealthKitManager().gettingLastFewWeeksHeartRate { heartRates in
                    for i in 0...13 {
                        model[i].heartRate = heartRates[i]
                    }
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                HealthKitManager().gettingDistanceArr(14) { distArr, _ in
                    for i in 0...13 {
                        model[i].distance = distArr[i]
                    }
                    dispatchGroup.leave()
                }
                
                dispatchGroup.notify(queue: .main) {
                    for i in 0...13 {
                        let data = model[i]
                        self.mainPrompt += "\(data.date): \(Int(data.steps!)) steps, walked \(Int(data.distance!)) meters, \(Int(data.activeEnergy!) ) calories burned, \(Int(data.exerciseMinutes!) ) minutes of exercise, heart rate of \(Int(data.heartRate ?? 0)) bpm. "
                    }
                    self.loadStatusStr { statusStr in
                        print("status", statusStr)
                        self.mainPrompt += statusStr
                        print(self.mainPrompt)

                        Task {
                            let response = try await api.sendMessage(text: messagePrompt,
                                                                     model: "gpt-3.5-turbo",
                                                                     systemText: self.mainPrompt,
                                                                     temperature: 0.9)

                            completion!(response)
                        }
                        
                        
                    }
                    
                    
                }
            } catch {
                print(error.localizedDescription)
                completion!(error.localizedDescription)
            }
        }
        
        
        
    }
    
    func getGptStream(messagePrompt: String, completion:((String, Bool) -> Void)?) {
        let api = ChatGPTAPI(apiKey: apiKey)
        
        let dispatchGroup = DispatchGroup()
        Task {
            do {
                var model: [Model] = []
                let cal = Calendar.current
                let today = Date()
                
                for day in 1...14 {
                    guard let endDate = cal.date(byAdding: .day, value: -day, to: today) else { continue }
                    model.append(Model(date: DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .none)))
                }
                
                dispatchGroup.enter()
                HealthKitManager().gettingLastFewWeeksStepCount { steps in
                    for i in 0...13 {
                        model[i].steps = steps[i]
                    }
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                HealthKitManager().gettingLastFewWeeksActiveEnergy { energies in
                    for i in 0...13 {
                        model[i].activeEnergy = energies[i]
                    }
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                HealthKitManager().gettingLastFewWeeksExerciseTime { exercises in
                    for i in 0...13 {
                        model[i].exerciseMinutes = exercises[i]
                    }
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                HealthKitManager().gettingLastFewWeeksHeartRate { heartRates in
                    print(heartRates)
                    for i in 0...13 {
                        model[i].heartRate = heartRates[i]
                    }
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                HealthKitManager().gettingDistanceArr(14) { distArr, _ in
                    for i in 0...13 {
                        model[i].distance = distArr[i]
                    }
                    dispatchGroup.leave()
                }
                
                dispatchGroup.notify(queue: .main) {
                    for i in 0...13 {
                        let data = model[i]
                        self.mainPrompt += "\(data.date): \(Int(data.steps!)) steps, walked \(Int(data.distance!)) meters, \(Int(data.activeEnergy!) ) calories burned, \(Int(data.exerciseMinutes!) ) minutes of exercise, heart rate of \(Int(data.heartRate ?? 0)) bpm. "
                    }
                    
                    self.loadStatusStr { statusStr in
                        print("status", statusStr)
                        self.mainPrompt += statusStr
                        print(self.mainPrompt)

                        Task {
                            do {
                                let stream = try await api.sendMessageStream(text: messagePrompt + " Do not start your answer with: Based on xxxx.",
                                                                             model: "gpt-3.5-turbo",
                                                                             systemText: self.mainPrompt,
                                                                             temperature: 0.9)
                                for try await line in stream {
                                    print(line)
                                    completion!(line, false)
                                }

                                completion!("", true)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        
                        
                    }
                    
                    
                }
            } catch {
                print(error.localizedDescription)
                completion!(error.localizedDescription, false)
            }
        }
    }
    
    private func loadStatusStr(_ completion: @escaping (String) -> Void) {
        var originalPrompt: String = ""
        
        self.db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                let age = doc["age"] as? Double
                let height = doc["height"] as? Double
                let weight = doc["weight"] as? Double
                let gender = doc["gender"] as? String
                
                if age != nil {
                    originalPrompt += " I am \(String(describing: age!)) years old. "
                }
                if gender != nil && gender != "" {
                    originalPrompt += "I am a \(String(describing: gender!)). "
                }
                if weight != nil {
                    originalPrompt += "I weigh \(String(describing: weight!)) kg. "
                }
                if height != nil {
                    originalPrompt += "And I am \(String(describing: height!)) cm tall. "
                }
                
                self.db.getUserDietaryFilter { filterDocSnapshot in
                    for filterDoc in filterDocSnapshot {
                        let bloodSugarLevel = filterDoc["bloodSugarLevel"] as? String
                        let cholesterolLevel = filterDoc["cholesterolLevel"] as? String
                        let cusinePreferences = filterDoc["cusinePreferences"] as? String
                        let dietGoal = filterDoc["dietGoal"] as? String
                        let dietaryPreferences = filterDoc["dietaryPreferences"] as? String
                        let foodAlergies = filterDoc["foodAlergies"] as? [String]
                        let otherInfo = filterDoc["otherInfo"] as? String
                        
                        if bloodSugarLevel != nil && bloodSugarLevel != "" {
                            originalPrompt += "My blood sugar level is \(bloodSugarLevel!) mg/dL. "
                        }
                        if cholesterolLevel != nil  && cholesterolLevel != "" {
                            originalPrompt += "My cholesterol level is \(cholesterolLevel!) mg/dL. "
                        }
                        if cusinePreferences != nil && cusinePreferences != "" {
                            originalPrompt += "My preferred cuisine style is \(cusinePreferences!) dishes. "
                        }
                        if dietGoal != nil && dietGoal != ""{
                            originalPrompt += "My diet goal is to \(dietGoal!). "
                        }
                        if dietaryPreferences != nil && dietaryPreferences != "" {
                            originalPrompt += "My dietary restriction is \(dietaryPreferences!). "
                        }
                        if foodAlergies != nil {
                            var foodAlergiesStr = ""
                            if foodAlergies!.count > 0 {
                                for i in 0..<foodAlergies!.count {
                                    foodAlergiesStr += (foodAlergies![i] + ", ")
                                }
                                originalPrompt += "I am alergic to the following food: \(foodAlergiesStr). "
                            }
                        }
                        if otherInfo != nil && otherInfo != "" {
                            originalPrompt += "Watch out for the following information: \(otherInfo!). "
                        }
                    }
                    
                    self.getActivities { (TDEE, ActLevel, ActCal, MealCal, Meals) in
                        originalPrompt += "My TDEE calories is \(TDEE). "
                        originalPrompt += "My activity level is \(ActLevel). "
                        originalPrompt += "My active calory consumed is \(ActCal). "
                        originalPrompt += "My calory intake from food so far is \(MealCal). "
                        originalPrompt += Meals
                    }
                    
                  
                    completion(originalPrompt)
                   
                }
            }
        }
    }
    
    private func getActivities(_ completion:@escaping((String, String, String, String, String))->Void?) {
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["weight"] != nil && doc["weight"] as? Double != nil
                    && doc["height"] != nil && doc["height"] as? Double != nil
                    && doc["gender"] != nil && doc["gender"] as? String != nil
                    && doc["age"] != nil && doc["age"] as? Double != nil
                {
                    var activeLevel: String = ""
                    var activeLevelFactor: Double = 0
                    HealthKitManager().gettingActivityLevel(date: Date()) { cal in
                        print("active level", cal)
                        if Double(cal).truncate(places: 2) <= 1000.0 {
                            activeLevel = "Sedantary"
                            activeLevelFactor = 1.2
                        }
                        else if Double(cal).truncate(places: 2) > 1000.0 && Double(cal).truncate(places: 2) <= 2000.0 {
                            activeLevel = "Low Active"
                            activeLevelFactor = 1.375
                        }
                        else if Double(cal).truncate(places: 2) > 2000.0 && Double(cal).truncate(places: 2) <= 3000.0 {
                            activeLevel = "Active"
                            activeLevelFactor = 1.55
                        }
                        else {
                            activeLevel = "Very Active"
                            activeLevelFactor = 1.725
                        }
                        let weight = doc["weight"] as! Double
                        let height = doc["height"] as! Double
                        let age = doc["age"] as! Double
                        let gender = doc["gender"] as! String
                        
                        var s: Double = 0
                        
                        if gender == "Male" {
                            s = 5
                        }
                        else {
                            s = -161
                        }
                        
                        let BMR = 10 * weight + 6.25 * height - 5 * age + s
                        let TDEE = BMR * activeLevelFactor
                        var mealCal: Double? = 0
                        
                        let mealHist = doc["mealHist"] as? [Any]
                        let today = Date()
                        var mealStr = ""
                        
                        if mealHist == nil || mealHist!.count == 0 {
                            mealCal = 0
                        } else {
                            for i in 0..<mealHist!.count {
                                let meal = mealHist![i] as! [String: Any]
                                let breakfast = meal["breakfast"] as? [String: Any]
                                let lunch = meal["lunch"] as? [String: Any]
                                let dinner = meal["dinner"] as? [String: Any]
                                
                                var breakfastCal = 0.0
                                if breakfast != nil {
                                    breakfastCal = breakfast!["mealCalories"] as? Double ?? 0.0
                                    let breakfastName = breakfast!["mealName"] as? String ?? ""
                                    mealStr += " Today I ate \(breakfastName) as my breakfast with \(breakfastCal) calories. "
                                }
                                var lunchCal = 0.0
                                if lunch != nil {
                                    lunchCal = lunch!["mealCalories"] as? Double ?? 0.0
                                    let lunchName = lunch!["mealName"] as? String ?? ""
                                    mealStr += " Today I ate \(lunchName) as my lunch with \(lunchCal) calories. "
                                }
                                var dinnerCal = 0.0
                                if dinner != nil {
                                    dinnerCal = dinner!["mealCalories"] as? Double ?? 0.0
                                    let dinnerName = dinner!["mealName"] as? String ?? ""
                                    mealStr += " Today I ate \(dinnerName) as my dinner with \(dinnerCal) calories. "
                                }
                                
                                let date = (meal["date"] as! Timestamp).dateValue()
                                if self.isSameDay(today, date) {
                                    mealCal = breakfastCal + lunchCal + dinnerCal
                                }
                            }
                        }
                        
                        
                        
                        completion(("\(TDEE.truncate(places: 2))", activeLevel, "\(Double(cal).truncate(places: 2))", "\(String(describing: mealCal!))", mealStr))
                        
                        //                        DispatchQueue.main.async {
                        //                            self.activeCal.text = "\(Double(cal).truncate(places: 2))"
                        //                            self.activityLevel.text = activeLevel
                        //                            self.TDEEText.text = "\(TDEE.truncate(places: 2))"
                        //                            self.mealCal.text = "\(String(describing: mealCal!))"
                        //                        }
                    }
                }
            }
        }
        
    }
    
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        return components1.year == components2.year &&
        components1.month == components2.month &&
        components1.day == components2.day
    }
    
    
}
