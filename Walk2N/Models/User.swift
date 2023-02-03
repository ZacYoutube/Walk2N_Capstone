//
//  User.swift
//  Walk2N
//
//  Created by Zhiquan You on 1/30/23.
//

import Foundation

class User {
    var uid: String = ""
    var email: String = ""
    var password: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var balance: Float = 0.0
    var boughtShoes: Array<Shoe> = []
    var currentShoe: Shoe?
    var historicalSteps: Array<HistoricalStep> = []
    var reachedStepGoal: Bool = false
    var stepGoalToday: Int = 0
    var weight: Float = 0
    var height: Float = 0
    var age: Int = 0
    
    init(uid: String, email: String, password: String,
         firstName: String, lastName: String,
         balance: Float, boughtShoes: Array<Shoe>,
         currentShoe: Shoe, historicalSteps: Array<HistoricalStep>, reachedStepGoal: Bool, stepGoalToday: Int, weight: Float, height: Float, age: Int) {
        self.uid = uid
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.balance = balance
        self.boughtShoes = boughtShoes
        self.currentShoe = currentShoe
        self.historicalSteps = historicalSteps
        self.reachedStepGoal = reachedStepGoal
        self.stepGoalToday = stepGoalToday
        self.weight = weight
        self.height = height
        self.age = age
    }
    
    func setFirstName(_ firstName: String){
        self.firstName = firstName
    }
    func setLast(_ lastName: String){
        self.lastName = lastName
    }
    func setBalance(_ balance: Float){
        self.balance = balance
    }
    func setBoughtShoes(_ boughtShoes: Array<Shoe>){
        self.boughtShoes = boughtShoes
    }
    func setCurrentShoe(_ currentShoe: Shoe){
        self.currentShoe = currentShoe
    }
    func setHistoricalSteps(_ historicalSteps: Array<HistoricalStep>){
        self.historicalSteps = historicalSteps
    }
    func setReachedStepGoal(_ reachedStepGoal: Bool){
        self.reachedStepGoal = reachedStepGoal
    }
    func setStepGoalToday(_ stepGoalToday: Int){
        self.stepGoalToday = stepGoalToday
    }
    
    func weight(_ weight: Float) {
        self.weight = weight
    }
    
    func height(_ height: Float) {
        self.height = height
    }
    
    func age(_ age: Int) {
        self.age = age
    }
}
