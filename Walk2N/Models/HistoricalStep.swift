//
//  HistoricalStep.swift
//  Walk2N
//
//  Created by Zhiquan You on 1/30/23.
//

import Foundation

public class HistoricalStep {
    var id: String?
    var uid: String?
    var stepCount: Int?
    var date: Date?
    var reachedGoal: Bool?
    var wearShoe: Bool?
    var stepGoal: Double?
    
    init(id: String?, uid: String?, stepCount: Int?, date: Date?, reachedGoal: Bool?, wearShoe: Bool?, stepGoal: Double?) {
        self.id = id
        self.uid = uid
        self.stepCount = stepCount
        self.date = date
        self.reachedGoal = reachedGoal
        self.wearShoe = wearShoe
        self.stepGoal = stepGoal
    }
    
    var firestoreData: [String: Any] {
        return [
            "id": id as Any,
            "uid": uid as Any,
            "stepCount": stepCount as Any,
            "date": date as Any,
            "reachedGoal": reachedGoal as Any,
            "wearShoe": wearShoe as Any,
            "stepGoal": stepGoal as Any
        ]
    }
    
}
