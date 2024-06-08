import HealthKit

class HealthStoreManager: ObservableObject {
    private var healthStore: HKHealthStore?
    private var stepCountAnchor: HKQueryAnchor?
    private var distanceAnchor: HKQueryAnchor?
    
    @Published var stepCount: Int = 0
    @Published var distance: Double = 0.0
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            
            let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            
            healthStore?.requestAuthorization(toShare: [], read: [stepType, distanceType]) { (success, error) in
                if success {
                    self.startStepCountQuery()
                    self.startDistanceQuery()
                }
            }
        }
    }
    
    func startStepCountQuery() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] (_, completionHandler, error) in
            if let self = self {
                self.fetchStepCount(completionHandler: completionHandler)
            } else {
                completionHandler()
            }
        }
        healthStore?.execute(query)
        healthStore?.enableBackgroundDelivery(for: stepType, frequency: .immediate, withCompletion: { _, _ in })
    }
    
    func fetchStepCount(completionHandler: @escaping () -> Void = {}) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                completionHandler()
                return
            }
            DispatchQueue.main.async {
                self.stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                completionHandler()
            }
        }
        healthStore?.execute(query)
    }
    
    func startDistanceQuery() {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        
        let query = HKObserverQuery(sampleType: distanceType, predicate: nil) { [weak self] (_, completionHandler, error) in
            if let self = self {
                self.fetchDistance(completionHandler: completionHandler)
            } else {
                completionHandler()
            }
        }
        healthStore?.execute(query)
        healthStore?.enableBackgroundDelivery(for: distanceType, frequency: .immediate, withCompletion: { _, _ in })
    }
    
    func fetchDistance(completionHandler: @escaping () -> Void = {}) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                completionHandler()
                return
            }
            DispatchQueue.main.async {
                self.distance = sum.doubleValue(for: HKUnit.meter())
                completionHandler()
            }
        }
        healthStore?.execute(query)
    }
}

extension Date {
    static var startOfDay: Date {
        return Calendar.current.startOfDay(for: Date())
    }
}
