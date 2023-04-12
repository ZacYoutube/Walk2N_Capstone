//
//  Meal.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/5/23.
//

import Foundation
import UIKit


class Meal {
    var mealName: String?
    var mealCalories: Double?
    var mealCarbs: Double?
    var mealProtein: Double?
    var mealFat: Double?
    var mealImg: String?
    var ingredients: [Any]?
    var procedures: [Any]?
    var estimatedCookTime: String?
    var mealType: String?
    
    init(mealName: String?, mealCalories: Double?, mealCarbs: Double?, mealProtein: Double?, mealFat: Double?, mealImg: String?) {
        self.mealName = mealName
        self.mealCalories = mealCalories
        self.mealCarbs = mealCarbs
        self.mealProtein = mealProtein
        self.mealFat = mealFat
        self.mealImg = mealImg
    }
    
    func setIngredients(ingredients: [Any]?) {
        self.ingredients = ingredients
    }
    
    func setProcedures(procedures: [Any]?) {
        self.procedures = procedures
    }
    
    func setEstimatedCookTime(estimatedCookTime: String?) {
        self.estimatedCookTime = estimatedCookTime
    }
    
    func setMealType(mealType: String?) {
        self.mealType = mealType
    }
    
    var firestoreData: [String: Any] {
        return [
            "mealName": mealName as Any,
            "mealCalories": mealCalories as Any,
            "mealCarbs": mealCarbs as Any,
            "mealProtein": mealProtein as Any,
            "mealFat": mealFat as Any,
            "mealImg": mealImg as Any,
            "ingredients": ingredients as Any,
            "procedures": procedures as Any,
            "estimatedCookTime": estimatedCookTime as Any
        ]
    }
}
