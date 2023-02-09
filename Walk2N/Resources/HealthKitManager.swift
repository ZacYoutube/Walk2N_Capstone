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
//        let formatter1 = DateFormatter()
//        formatter1.dateFormat = "MM/dd/yy"
//        return formatter1.string(from: date)
        return date.dayOfWeek()!
    }
    
    // this function retrieves the past 7 days of step counts from Health app
    func gettingStepCount(_ n: Int, completion:(([Double], [Date]) -> Void)?){
         guard let sampleType = HKCategoryType.quantityType(forIdentifier: .stepCount) else {
             return
         }
         var stepOverPastNDays: Array<Double> = []
         var time: Array<Date> = []
         let now = Date()
         let exactlyNDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -n), to: now)!
         let startOfNDaysAgo = Calendar.current.startOfDay(for: exactlyNDaysAgo)
         var predicate = HKQuery.predicateForSamples(withStart: exactlyNDaysAgo, end: now, options: .strictEndDate)
         if n == 0 {
             predicate = HKQuery.predicateForSamples(withStart: startOfNDaysAgo, end: now, options: .strictEndDate)
         }
         var interval = DateComponents()
         interval.day = 1
         let query = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: predicate, anchorDate: startOfNDaysAgo, intervalComponents: interval)
         query.initialResultsHandler = {
             query, result, err in
             if let res = result {
                 res.enumerateStatistics(from: startOfNDaysAgo, to: now) { stats, val in
                     if let count = stats.sumQuantity() {
                         let val = count.doubleValue(for: HKUnit.count())
                         let date = stats.startDate
                         stepOverPastNDays.append(val)
                         time.append(date)
                     }
                 }
                 completion!(stepOverPastNDays, time)
             }
         }
         healthStore.execute(query)
     }
}
