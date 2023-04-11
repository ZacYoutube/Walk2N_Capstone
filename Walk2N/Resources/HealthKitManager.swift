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
            let activitySummaryType: Set = [HKObjectType.activitySummaryType()]
            healthStore.requestAuthorization(toShare: nil, read: (stepCount as! Set<HKObjectType>)) { success, err in
                isEnabled = success
            }
            healthStore.requestAuthorization(toShare: nil, read: (distance as! Set<HKObjectType>)) { success, err in
                isEnabled = success
            }
            healthStore.requestAuthorization(toShare: nil, read: activitySummaryType) { (success, error) in
                isEnabled = success
            }
        }else{
            isEnabled = false
        }
        
        return isEnabled
    }
    
    func convertDateToStr(date: Date) -> String {
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
    
    func getDistOnSpecificDate(_ date: Date, completion:((Double) -> Void)?) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let startDate = calendar.date(from: components)!
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
            if let result = result {
                if let distance = result.sumQuantity() {
                    let distanceInMeters = distance.doubleValue(for: HKUnit.meter())
                    completion!(distanceInMeters)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func gettingDistanceArr(_ n: Int, completion:(([Double], [Date]) -> Void)?){
        guard let type = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            fatalError("Something went wrong retriebing quantity type distanceWalkingRunning")
        }
        let now = Date()
        let exactlyNDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -n), to: now)!
        let startOfNDaysAgo = Calendar.current.startOfDay(for: exactlyNDaysAgo)
        var predicate = HKQuery.predicateForSamples(withStart: exactlyNDaysAgo, end: now, options: .strictEndDate)
        var distanceArr: [Double] = []
        var distanceDate: [Date] = []
        if n == 0 {
            predicate = HKQuery.predicateForSamples(withStart: startOfNDaysAgo, end: now, options: .strictEndDate)
        }
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: predicate, anchorDate: startOfNDaysAgo, intervalComponents: interval)
        query.initialResultsHandler = {
            query, result, err in
            if let res = result {
                res.enumerateStatistics(from: startOfNDaysAgo, to: now) { stats, val in
                    if let count = stats.sumQuantity() {
                        let val = count.doubleValue(for: HKUnit.meter())
                        let date = stats.startDate
                        distanceArr.append(val)
                        distanceDate.append(date)
                    }
                }
                completion!(distanceArr, distanceDate)
            }
        }
        
        query.statisticsUpdateHandler = {
            query, statistics, result, error in
            if let res = result {
                res.enumerateStatistics(from: startOfNDaysAgo, to: now) { stats, val in
                    if let count = stats.sumQuantity() {
                        let val = count.doubleValue(for: HKUnit.meter())
                        let date = stats.startDate
                        distanceArr.append(val)
                        distanceDate.append(date)
                    }
                }
                completion!(distanceArr, distanceDate)
            }
        }
        healthStore.execute(query)
    }
    
    func gettingActivityLevel(completion:(([Double]) -> Void)?) {
        let calendar = Calendar.current
        let now = calendar.dateComponents([.year, .month, .day, .calendar], from: Date())

        let predicate = HKQuery.predicateForActivitySummary(with: now)
        let query = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
            if let error = error {
                // Handle error
                print(error)
                return
            }
            if let summary = summaries?.first {
                // Use the activity summary data
                let activeEnergyBurned = summary.activeEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
                let samplesQuery = HKSampleQuery(sampleType: HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                    if let error = error {
                        // Handle error
                        print(error)
                        return
                    }
                    if let sample = samples?.first as? HKQuantitySample {
                        let restingEnergyBurned = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
                        let totalEnergyBurned = activeEnergyBurned + restingEnergyBurned
                        let standingHours = summary.appleStandHours.doubleValue(for: HKUnit.count())
                        let exerciseMinutes = summary.appleExerciseTime.doubleValue(for: HKUnit.minute())
                        
                        print("Active energy burned: \(activeEnergyBurned) kcal")
                        print("Resting energy burned: \(restingEnergyBurned) kcal")
                        print("Total energy burned: \(totalEnergyBurned) kcal")
                        print("Standing hours: \(standingHours) hours")
                        print("Exercise minutes: \(exerciseMinutes) minutes")
                        
                        completion!([restingEnergyBurned, activeEnergyBurned, standingHours, exerciseMinutes])
                    }
                }
                self.healthStore.execute(samplesQuery)
            }
        }
        healthStore.execute(query)
    }
}
