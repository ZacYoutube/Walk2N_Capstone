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
    
    init(id: String?, uid: String?, stepCount: Int?, date: Date?, reachedGoal: Bool?) {
        self.id = id
        self.uid = uid
        self.stepCount = stepCount
        self.date = date
        self.reachedGoal = reachedGoal
    }
    
    var firestoreData: [String: Any] {
            return [
                "id": id as Any,
                "uid": uid as Any,
                "stepCount": stepCount as Any,
                "date": date as Any,
                "reachedGoal": reachedGoal as Any
            ]
    }
    
    func setStepCount(_ step: Int){
        self.stepCount = step
    }
    func setDate(_ date: Date){
        self.date = date
    }
    
    func setReachedGoal(_ reachedGoal: Bool) {
        self.reachedGoal = reachedGoal
    }
   
}
