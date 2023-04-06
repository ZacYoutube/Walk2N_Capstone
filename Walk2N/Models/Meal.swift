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
    var mealImg: UIImage?
    
    init(mealName: String?, mealCalories: Double?, mealCarbs: Double?, mealProtein: Double?, mealFat: Double?, mealImg: UIImage?) {
        self.mealName = mealName
        self.mealCalories = mealCalories
        self.mealCarbs = mealCarbs
        self.mealProtein = mealProtein
        self.mealFat = mealFat
        self.mealImg = mealImg
    }
    
    var firestoreData: [String: Any] {
        return [
            "mealName": mealName as Any,
            "mealCalories": mealCalories as Any,
            "mealCarbs": mealCarbs as Any,
            "mealProtein": mealProtein as Any,
            "mealFat": mealFat as Any,
            "mealImg": mealImg as Any
        ]
    }
}
