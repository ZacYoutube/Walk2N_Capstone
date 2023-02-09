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
    var durability: Float?
    var imgUrl: String?
    var price: Float?
    var expirationDate: Date?
    
    init(id: String?, name: String?, durability: Float?, imgUrl: String?, price: Float?, expirationDate: Date?) {
        self.id = id
        self.name = name
        self.durability = durability
        self.imgUrl = imgUrl
        self.price = price
        self.expirationDate = expirationDate
    }
    
    var firestoreData: [String: Any] {
            return [
                "id": id as Any,
                "name": name as Any,
                "durability": durability as Any,
                "imgUrl": imgUrl as Any,
                "price": price as Any,
                "expirationDate": expirationDate as Any,
                "boughtDate": Date()
            ]
    }
    
    func setDurability(_ d: Float){
        self.durability = d
    }
    func setName(_ name: String){
        self.name = name
    }
    func setPrice(_ price: Float){
        self.price = price
    }
    func setImgUrl(_ imgUrl: String){
        self.imgUrl = imgUrl
    }
    func setExpirationDate(_ expirationDate: Date) {
        self.expirationDate = expirationDate
    }
}
