//
//  HealthStoreManager.swift
//  StepTrackerSwiftUI
//
//  Created by Rangga Biner on 08/06/24.
//

import HealthKit

// Kelas untuk mengelola data HealthKit dan berfungsi sebagai ObservableObject untuk SwiftUI
class HealthStoreManager: ObservableObject {
    private var healthStore: HKHealthStore? // Objek untuk berinteraksi dengan HealthKit
    private var stepCountAnchor: HKQueryAnchor? // Anchor untuk query step count
    private var distanceAnchor: HKQueryAnchor? // Anchor untuk query jarak
    
    @Published var stepCount: Int = 0 // Properti yang dipublikasikan untuk jumlah langkah
    @Published var distance: Double = 0.0 // Properti yang dipublikasikan untuk jarak
    
    // Initializer untuk menginisialisasi objek HealthStoreManager
    init() {
        if HKHealthStore.isHealthDataAvailable() { // Cek jika data HealthKit tersedia
            healthStore = HKHealthStore() // Inisialisasi healthStore
            
            // Mendapatkan tipe data step count dan distance
            let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            
            // Meminta otorisasi untuk membaca data HealthKit
            healthStore?.requestAuthorization(toShare: [], read: [stepType, distanceType]) { (success, error) in
                if success {
                    self.startStepCountQuery() // Memulai query step count jika otorisasi berhasil
                    self.startDistanceQuery() // Memulai query distance jika otorisasi berhasil
                }
            }
        }
    }
    
    // Memulai query untuk step count
    func startStepCountQuery() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        // Membuat observer query untuk step count
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] (_, completionHandler, error) in
            if let self = self {
                self.fetchStepCount(completionHandler: completionHandler) // Fetch step count data
            } else {
                completionHandler()
            }
        }
        healthStore?.execute(query) // Menjalankan query
        healthStore?.enableBackgroundDelivery(for: stepType, frequency: .immediate, withCompletion: { _, _ in }) // Mengaktifkan pengiriman latar belakang
    }
    
    // Mengambil data step count
    func fetchStepCount(completionHandler: @escaping () -> Void = {}) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        // Membuat predicate untuk mengambil data dari awal hari hingga saat ini
        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)
        
        // Membuat statistics query untuk step count
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                completionHandler()
                return
            }
            DispatchQueue.main.async {
                self.stepCount = Int(sum.doubleValue(for: HKUnit.count())) // Update step count
                completionHandler()
            }
        }
        healthStore?.execute(query) // Menjalankan query
    }
    
    // Memulai query untuk distance
    func startDistanceQuery() {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        
        // Membuat observer query untuk distance
        let query = HKObserverQuery(sampleType: distanceType, predicate: nil) { [weak self] (_, completionHandler, error) in
            if let self = self {
                self.fetchDistance(completionHandler: completionHandler) // Fetch distance data
            } else {
                completionHandler()
            }
        }
        healthStore?.execute(query) // Menjalankan query
        healthStore?.enableBackgroundDelivery(for: distanceType, frequency: .immediate, withCompletion: { _, _ in }) // Mengaktifkan pengiriman latar belakang
    }
    
    // Mengambil data distance
    func fetchDistance(completionHandler: @escaping () -> Void = {}) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        
        // Membuat predicate untuk mengambil data dari awal hari hingga saat ini
        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)
        
        // Membuat statistics query untuk distance
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                completionHandler()
                return
            }
            DispatchQueue.main.async {
                self.distance = sum.doubleValue(for: HKUnit.meter()) // Update distance
                completionHandler()
            }
        }
        healthStore?.execute(query) // Menjalankan query
    }
}

// Ekstensi untuk mendapatkan awal hari dari tanggal saat ini
extension Date {
    static var startOfDay: Date {
        return Calendar.current.startOfDay(for: Date())
    }
}
