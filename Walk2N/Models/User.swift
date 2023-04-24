//
//  User.swift
//  Walk2N
//
//  Created by Zhiquan You on 1/30/23.
//

import Foundation

public class User {
    var uid: String?
    var email: String?
    var password: String?
    var firstName: String?
    var lastName: String?
    var balance: Float?
    var boughtShoes: Array<Shoe>?
    var currentShoe: Shoe?
    var historicalSteps: Array<HistoricalStep>?
    var bonusEarnedToday: Double?
    var stepGoalToday: Int?
    var weight: Float?
    var height: Float?
    var age: Int?
    var gender: String?
    var bonusHistory: Array<String>?
    var bonusAwardedForReachingStepGoal: Bool?
    var bonusEarnedDuringRealTimeRun: Double?
    var profileImgUrl: String?
    var alertHist: Array<Alert>?
    var mealHist: Array<MealHist>?
    
    init(uid: String?, email: String?, password: String?,
         firstName: String?, lastName: String?,
         balance: Float?, boughtShoes: Array<Shoe>?,
         currentShoe: Shoe?, historicalSteps: Array<HistoricalStep>?,
         bonusEarnedToday: Double?, stepGoalToday: Int?, weight: Float?,
         height: Float?, age: Int?, gender: String?, bonusHistory: Array<String>?,
         bonusAwardedForReachingStepGoal: Bool?, bonusEarnedDuringRealTimeRun: Double?,
         profileImgUrl: String?, alertHist: Array<Alert>?, mealHist: Array<MealHist>?) {
        self.uid = uid
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.balance = balance
        self.boughtShoes = boughtShoes
        self.currentShoe = currentShoe
        self.historicalSteps = historicalSteps
        self.bonusEarnedToday = bonusEarnedToday
        self.stepGoalToday = stepGoalToday
        self.weight = weight
        self.height = height
        self.age = age
        self.gender = gender
        self.bonusHistory = bonusHistory
        self.bonusAwardedForReachingStepGoal = bonusAwardedForReachingStepGoal
        self.bonusEarnedDuringRealTimeRun = bonusEarnedDuringRealTimeRun
        self.profileImgUrl = profileImgUrl
        self.alertHist = alertHist
        self.mealHist = mealHist
    }
}
