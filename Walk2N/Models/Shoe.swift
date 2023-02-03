//
//  Shoe.swift
//  Walk2N
//
//  Created by Zhiquan You on 1/30/23.
//

import Foundation

class Shoe {
    var id: String = ""
    var name: String = ""
    var durability: Float = 0.0
    var imgUrl: String = ""
    var price: Float = 0.0
    
    init(id: String, name: String, durability: Float, imgUrl: String, price: Float) {
        self.id = id
        self.name = name
        self.durability = durability
        self.imgUrl = imgUrl
        self.price = price
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
}
