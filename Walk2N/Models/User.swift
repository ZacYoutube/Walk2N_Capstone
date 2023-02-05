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
    var reachedStepGoal: Bool?
    var stepGoalToday: Int?
    var weight: Float?
    var height: Float?
    var age: Int?
    var gender: String?
    
    init(uid: String?, email: String?, password: String?,
         firstName: String?, lastName: String?,
         balance: Float?, boughtShoes: Array<Shoe>?,
         currentShoe: Shoe?, historicalSteps: Array<HistoricalStep>?,
         reachedStepGoal: Bool?, stepGoalToday: Int?, weight: Float?,
         height: Float?, age: Int?, gender: String?) {
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
        self.gender = gender
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
    
    func setWeight(_ weight: Float) {
        self.weight = weight
    }
    
    func setHeight(_ height: Float) {
        self.height = height
    }
    
    func setAge(_ age: Int) {
        self.age = age
    }
    
    func setGender(_ gender: String){
        self.gender = gender
    }
}
