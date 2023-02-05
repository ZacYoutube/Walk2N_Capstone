//
//  Shoe.swift
//  Walk2N
//
//  Created by Zhiquan You on 1/30/23.
//

import Foundation

public class Shoe {
    var id: String?
    var name: String?
    var durability: Float?
    var imgUrl: String?
    var price: Float?
    
    init(id: String?, name: String?, durability: Float?, imgUrl: String?, price: Float?) {
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
