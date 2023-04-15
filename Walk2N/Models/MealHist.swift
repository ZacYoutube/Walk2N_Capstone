//
//  MealHist.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/9/23.
//

import Foundation

class MealHist {

    var uid: String?
    var breakfast: Meal?
    var lunch: Meal?
    var dinner: Meal?
    var date: Date?
    
    init(uid: String?, breakfast: Meal?, lunch: Meal?, dinner: Meal?, date: Date?) {
        self.uid = uid
        self.breakfast = breakfast
        self.lunch = lunch
        self.dinner = dinner
        self.date = date
    }
    
    var firestoreData: [String: Any] {
        return [
            "breakfast": breakfast?.firestoreData as Any,
            "lunch": lunch?.firestoreData as Any,
            "dinner": dinner?.firestoreData as Any,
            "date": date as Any,
            "uid": uid as Any
        ]
    }
}
