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
    
    // this function retrieves the past n days of step counts from Health app
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
        query.statisticsUpdateHandler = {
            query, statistics, result, error in
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
    
    func getStepCountBetweenTimestamps(startDate: Date, endDate: Date, completion: @escaping (Double, Error?) -> Void) {
                
        let stepsCount = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKSampleQuery(sampleType: stepsCount, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            guard error == nil else {
                completion(0, error)
                return
            }
            
            var stepCount = 0.0
            for sample in samples as! [HKQuantitySample] {
                let quantity = sample.quantity
                let count = quantity.doubleValue(for: HKUnit.count())
                stepCount += count
            }
            
            completion(stepCount, nil)
        }
        
        healthStore.execute(query)
    }
    
    
    
    func gettingDistance(_ n: Int, completion:((Double) -> Void)?){
        guard let type = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            fatalError("Something went wrong retriebing quantity type distanceWalkingRunning")
        }
        let now = Date()
        let exactlyNDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -n), to: now)!
        let startOfNDaysAgo = Calendar.current.startOfDay(for: exactlyNDaysAgo)
        var predicate = HKQuery.predicateForSamples(withStart: exactlyNDaysAgo, end: now, options: .strictEndDate)
        if n == 0 {
            predicate = HKQuery.predicateForSamples(withStart: startOfNDaysAgo, end: now, options: .strictEndDate)
        }

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
            var value: Double = 0

            if error != nil {
                print("something went wrong")
            } else if let quantity = statistics?.sumQuantity() {
                value = quantity.doubleValue(for: HKUnit.meterUnit(with: .kilo))
            }
            DispatchQueue.main.async {
                completion!(value)
            }
        }
        healthStore.execute(query)
    }
}
