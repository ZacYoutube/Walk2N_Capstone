//
//  Shoe.swift
//  Walk2N
//
//  Created by Zhiquan You on 1/30/23.
//

import Foundation

public class Shoe: Codable {
    var id: String?
    var name: String?
    var awardPerStep: Double?
    var imgUrl: String?
    var price: Double?
    var expirationDate: Date?
    
    init(id: String?, name: String?, awardPerStep: Double?, imgUrl: String?, price: Double?, expirationDate: Date?) {
        self.id = id
        self.name = name
        self.awardPerStep = awardPerStep
        self.imgUrl = imgUrl
        self.price = price
        self.expirationDate = expirationDate
    }
    
    var firestoreData: [String: Any] {
            return [
                "id": id as Any,
                "name": name as Any,
                "awardPerStep": awardPerStep as Any,
                "imgUrl": imgUrl as Any,
                "price": price as Any,
                "expirationDate": expirationDate as Any,
                "boughtDate": Date()
            ]
    }
}
