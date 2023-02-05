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
    
    init(id: String?, uid: String?, stepCount: Int?, date: Date?) {
        self.id = id
        self.uid = uid
        self.stepCount = stepCount
        self.date = date
    }
    
    func setStepCount(_ step: Int){
        self.stepCount = step
    }
    func setDate(_ date: Date){
        self.date = date
    }
   
}
