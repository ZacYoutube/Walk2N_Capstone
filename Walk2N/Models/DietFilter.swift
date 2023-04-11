//
//  Shoe.swift
//  Walk2N
//
//  Created by Zhiquan You on 1/30/23.
//

public class DietFilter: Codable {
    var uid: String?
    var bloodSugarLevel: String?
    var cholesterolLevel: String?
    var dietGoal: String?
    var foodAlergies: [String]?
    var dietaryPreferences: String?
    var cusinePreferences: String?
    var otherInfo: String?
    
    init(uid: String?, bloodSugarLevel: String?, cholesterolLevel: String?, dietGoal: String?, foodAlergies: [String]?, dietaryPreferences: String?, cusinePreferences: String?, otherInfo: String?) {
        self.uid = uid
        self.bloodSugarLevel = bloodSugarLevel
        self.cholesterolLevel = cholesterolLevel
        self.dietGoal = dietGoal
        self.foodAlergies = foodAlergies
        self.dietaryPreferences = dietaryPreferences
        self.cusinePreferences = cusinePreferences
        self.otherInfo = otherInfo
    }
    
    var firestoreData: [String: Any] {
        return [
            "uid": uid as Any,
            "bloodSugarLevel": bloodSugarLevel as Any,
            "cholesterolLevel": cholesterolLevel as Any,
            "dietGoal": dietGoal as Any,
            "foodAlergies": foodAlergies as Any,
            "dietaryPreferences": dietaryPreferences as Any,
            "cusinePreferences": cusinePreferences as Any,
            "otherInfo": otherInfo as Any
        ]
    }
}
