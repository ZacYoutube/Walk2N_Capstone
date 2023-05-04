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
        let types: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: types) { success, error in
            isEnabled = success
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
    
    func gettingStepCountBetweenTimestamps(startDate: Date, endDate: Date, completion: @escaping (Double, Error?) -> Void) {
        
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
    
    func gettingDistOnSpecificDate(_ date: Date, completion:((Double) -> Void)?) {
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
    
    func gettingActivityLevel(date: Date, completion:((Double) -> Void)?) {
        
        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            fatalError("Active Energy Burned data not available")
        }
        
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: activeEnergyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                return
            }
            
            let totalActiveEnergyBurned = samples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
            
            completion!(totalActiveEnergyBurned)
        }
        
        healthStore.execute(query)
        
    }
    
    func gettingLastFewDaysQuantityData(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, options: HKStatisticsOptions, days: Int, completion: @escaping ([Double]) -> Void) {
        let predicate = createDaysPredicate(days)
        let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: identifier)!, quantitySamplePredicate: predicate, options: options, anchorDate: Date().daysAgoStartOfDay(days), intervalComponents: DateComponents(day: 1))
        
        var dailyData: [Double] = []
        
        query.initialResultsHandler = { query, results, error in
            if let statsCollection = results {
                statsCollection.enumerateStatistics(from: Date().daysAgoStartOfDay(days), to: Date.startOfDay()) { statistics, _ in
                    if identifier == .heartRate {
                        if let quantity = statistics.maximumQuantity() {
                            let countPerSecond = quantity.doubleValue(for: unit.unitDivided(by: .second()))
                            let count = countPerSecond * 60
                            dailyData.append(count)
                        }
                        else {
                            dailyData.append(0)
                        }
                    } else {
                        if let quantity = statistics.sumQuantity() {
                            dailyData.append(quantity.doubleValue(for: unit))
                        } else {
                            dailyData.append(0)
                        }
                    }
                    
                }
                
                completion(dailyData)
            } else {
                completion([])
            }
        }
        
        healthStore.execute(query)
    }
    
    func gettingLastFewWeeksStepCount(completion: @escaping ([Double]) -> Void) {
        gettingLastFewDaysQuantityData(for: .stepCount, unit: HKUnit.count(), options: [.cumulativeSum], days: 14, completion: completion)
    }
    
    func gettingLastFewWeeksActiveEnergy(completion: @escaping ([Double]) -> Void) {
        gettingLastFewDaysQuantityData(for: .activeEnergyBurned, unit: HKUnit.largeCalorie(), options: [.cumulativeSum], days: 14, completion: completion)
    }
    
    func gettingLastFewWeeksExerciseTime(completion: @escaping ([Double]) -> Void) {
        gettingLastFewDaysQuantityData(for: .appleExerciseTime, unit: .minute(), options: [.cumulativeSum], days: 14, completion: completion)
    }
    
    func gettingLastFewWeeksHeartRate(completion: @escaping ([Double]) -> Void) {
        gettingLastFewDaysQuantityData(for: .heartRate, unit: .count(), options: [.discreteMax], days: 14, completion: completion)
    }

    private func createDaysPredicate(_ day: Int) -> NSPredicate {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -day), to: now)!
        return HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
    }
}
