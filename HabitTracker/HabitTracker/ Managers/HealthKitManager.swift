import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let types: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .dietaryWater)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.workoutType()
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: types) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
            }
        }
    }
    
    func checkTodayData(for type: HealthKitDataType, completion: @escaping (Bool) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        switch type {
        case .steps:
            checkSteps(predicate: predicate, completion: completion)
        case .water:
            checkWater(predicate: predicate, completion: completion)
        case .sleep:
            checkSleep(predicate: predicate, completion: completion)
        case .workout:
            checkWorkout(predicate: predicate, completion: completion)
        }
    }
    
    private func checkSteps(predicate: NSPredicate, completion: @escaping (Bool) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            DispatchQueue.main.async {
                completion(steps > 1000)
            }
        }
        healthStore.execute(query)
    }
    
    private func checkWater(predicate: NSPredicate, completion: @escaping (Bool) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let water = result?.sumQuantity()?.doubleValue(for: HKUnit.literUnit(with: .milli)) ?? 0
            DispatchQueue.main.async {
                completion(water > 500)
            }
        }
        healthStore.execute(query)
    }
    
    private func checkSleep(predicate: NSPredicate, completion: @escaping (Bool) -> Void) {
        let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            DispatchQueue.main.async {
                completion(samples?.isEmpty == false)
            }
        }
        healthStore.execute(query)
    }
    
    private func checkWorkout(predicate: NSPredicate, completion: @escaping (Bool) -> Void) {
        let query = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            DispatchQueue.main.async {
                completion(samples?.isEmpty == false)
            }
        }
        healthStore.execute(query)
    }
}
