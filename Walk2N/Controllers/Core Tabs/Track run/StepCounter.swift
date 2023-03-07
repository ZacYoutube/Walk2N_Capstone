//
//  StepCounter.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/11/23.
//

import CoreMotion

class StepCounter {
    let pedometer = CMPedometer()
    
    func startTracking(from startTime: Date,  completion: @escaping (Int?)->Void) {
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.startUpdates(from: startTime) { data, err in
                if err == nil {
                    if let res = data {
                        completion((res.numberOfSteps as! Int))
                    }
                }
            }
        }
    }
    
    func getSteps(from startTime: Date, completion: @escaping (Int?)->Void) {
        startTracking(from: startTime) { steps in
            print(steps)
        }
        
        self.pedometer.queryPedometerData(from: startTime, to: Date()) { data, err in
            if err == nil {
                let numberOfSteps = data!.numberOfSteps
                completion(Int(numberOfSteps.intValue))
            } else {
                completion(0)
            }
        }
        
        endTracking()
    }
    
    func endTracking() {
        self.pedometer.stopUpdates()
    }
    
//    func updateStepsRealtime(startTime: Date, completion:@escaping ((Double) -> Void)) {
//        if CMPedometer.isStepCountingAvailable() {
//            self.pedometer.startUpdates(from: startTime) { data, err in
//                if err == nil {
//                    if let res = data {
//                        completion(Double(res.numberOfSteps))
//                    }
//                }
//            }
//        }
//    }
}
