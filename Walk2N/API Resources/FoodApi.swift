//
//  FoodApi.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/12/23.
//

import Foundation

struct Nutrient {
    var totalNutrient: TotalNutrientsKCal
}

struct TotalNutrientsKCal {
    var carbsKCal: Double
    var proteinKCal: Double
    var fatKCal: Double
    var totalKCal: Double
    var percentages: [Double]
}

class FoodApiService {
    private let apiKey = ApiKeyObject.foodGovApiKey
    private let edamamApiKey = ApiKeyObject.edamamApiKey
    private let appId = ApiKeyObject.appId
    
    func getFoodResponse(query: String, completion:((Nutrient) -> Void)?) {

        let url = URL(string: "https://api.edamam.com/api/food-database/v2/parser?app_id=\(appId)&app_key=\(edamamApiKey)&ingr=\(query.replacingOccurrences(of: " ", with: "%20"))&nutrition-type=logging")

        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error!)")
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                let parsed = result!["parsed"] as? [Any]
                
                if parsed!.count > 0 {
                    let foodList = parsed![0] as! [String: Any]
                    let food = foodList["food"] as? [String: Any]
                    let nutrients = food!["nutrients"] as? [String: Any]
                    
                    let totalEnergy = nutrients!["ENERC_KCAL"] as? Double
                    
                    let proteinWeight = nutrients!["PROCNT"] as? Double
                    let fatWeight = nutrients!["FAT"] as? Double
                    let carbWeight = nutrients!["CHOCDF"] as? Double
                    
                    let totalWeight: Double = (proteinWeight?.truncate(places: 2))! + (fatWeight?.truncate(places: 2))! + (carbWeight?.truncate(places: 2))!
                    let proteinPercent = ((proteinWeight?.truncate(places: 2))! / totalWeight).truncate(places: 2)
                    let carbsPercent = ((carbWeight?.truncate(places: 2))! / totalWeight).truncate(places: 2)
                    let fatPercent = (1 - proteinPercent - carbsPercent).truncate(places: 2)

                    let nutrient = Nutrient(totalNutrient: TotalNutrientsKCal(carbsKCal: (carbWeight?.truncate(places: 2))!, proteinKCal: (proteinWeight?.truncate(places: 2))!, fatKCal: (fatWeight?.truncate(places: 2))!, totalKCal: totalEnergy!, percentages: [carbsPercent, proteinPercent, fatPercent]))
                    completion!(nutrient)
                } else {
                    let nutrient = Nutrient(totalNutrient: TotalNutrientsKCal(carbsKCal: 0, proteinKCal: 0, fatKCal: 0, totalKCal: 0, percentages: [0, 0, 0]))
                    completion!(nutrient)
                }
                
            } catch {
                print("Error: \(error)")
            }
        }

        task.resume()

    }
    
}
