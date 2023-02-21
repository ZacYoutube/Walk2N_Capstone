//
//  Bonus.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/19/23.
//

import Foundation

public class Bonus: Codable {
    var id: String?
    var amount: Double?
    var date: Date?
    
    init(id: String?, amount: Double?, date: Date?) {
        self.id = id
        self.amount = amount
        self.date = date
    }
    
    var firestoreData: [String: Any] {
            return [
                "id": id as Any,
                "amount": amount as Any,
                "date": date as Any
            ]
    }
}
