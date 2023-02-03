//
//  HealthKitManager.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/2/23.
//

import Foundation
import UIKit
import HealthKit

class HealthKitManager {
    let healthStore = HKHealthStore()
    
    
    // checks and get authorization from Health app for stepCount and distanceWalkingRunning metrics
    func authorizeHealthKit() -> Bool {
        var isEnabled = true
        if HKHealthStore.isHealthDataAvailable() {
            let stepCount = NSSet(object: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) as Any)
            let distance = NSSet(object: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) as Any)
            healthStore.requestAuthorization(toShare: nil, read: (stepCount as! Set<HKObjectType>)) { success, err in
                isEnabled = success
            }
            healthStore.requestAuthorization(toShare: nil, read: (distance as! Set<HKObjectType>)) { success, err in
                isEnabled = success
            }
        }else{
            isEnabled = false
        }
                
        return isEnabled
    }
    
    func convertDateToStr(date: Date) -> String {
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        return formatter1.string(from: date)
    }
    
    // this function retrieves the past 7 days of step counts from Health app
    func gettingStepCount(completion:(([Double], [String]) -> Void)?){
         guard let sampleType = HKCategoryType.quantityType(forIdentifier: .stepCount) else {
             return
         }
         var stepOverPast7Days: Array<Double> = []
         var time: Array<String> = []
         let now = Date()
         let exactlySevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -7), to: now)!
         let startOfSevenDaysAgo = Calendar.current.startOfDay(for: exactlySevenDaysAgo)
         let predicate = HKQuery.predicateForSamples(withStart: exactlySevenDaysAgo, end: now, options: .strictEndDate)
         var interval = DateComponents()
         interval.day = 1
         let query = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: predicate, anchorDate: startOfSevenDaysAgo, intervalComponents: interval)
         query.initialResultsHandler = {
             query, result, err in
             if let res = result {
                 res.enumerateStatistics(from: startOfSevenDaysAgo, to: now) { stats, val in
                     if let count = stats.sumQuantity() {
                         let val = count.doubleValue(for: HKUnit.count())
                         let date = stats.startDate
                         stepOverPast7Days.append(val)
                         time.append(self.convertDateToStr(date: date))
                     }
                 }
                 completion!(stepOverPast7Days, time)
             }
         }
         healthStore.execute(query)
     }
}
