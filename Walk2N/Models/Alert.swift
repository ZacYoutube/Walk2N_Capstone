//
//  Bonus.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/19/23.
//

import Foundation

public class Alert: Codable {
    var message: String?
    var date: Date?
    
    init(message: String?, date: Date?) {
        self.message = message
        self.date = date
    }
    
    var firestoreData: [String: Any] {
        return [
            "message": message as Any,
            "date": date as Any
        ]
    }
}
