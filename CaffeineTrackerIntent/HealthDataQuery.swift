//
//  HealthDataQuery.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 9/8/20.
//

import Foundation
import Foundation
import Swift
import HealthKit
import SwiftUI
import Combine

// **************** Class used to authorise access to HealthKit and fetch calories burned  **************** \\
class HealthDataQuery {
    static let shared = HealthDataQuery()
    let healthStore = HKHealthStore()
    let caffeineUnit = HKUnit.gram()
    
    // Request access to data from HealthKit
    func authorizeHealthKit() {
        // Check if HealthKit is available on the device
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        // Set reqest for ActivitySummary
        var typesToShare: Set<HKSampleType> {
            let caffeineType = HKObjectType.quantityType(forIdentifier: .dietaryCaffeine)!
            return [caffeineType]
        }
        
        // Perform the authorisation
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToShare) { (success, error) in
            if (success) {
                print(success)
                UserDefaults.standard.set(true, forKey: "isHealthDataAllowed")
            } else {
                if error != nil {
                    print(error ?? "Error")
                    UserDefaults.standard.set(false, forKey: "isHealthDataAllowed")
                }
            }
        }
    }

    func writeHealthDate(milligram: Double, date: Date) -> Void {
        var typesToShare: Set<HKSampleType> {
            let caffeineType = HKObjectType.quantityType(forIdentifier: .dietaryCaffeine)!
            return [caffeineType]
        }
        
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: typesToShare, read: nil) { (success, error) in
                if success {
                    //Initialize the type we are saving to.
                    guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine) else {
                        fatalError("*** Unable to create a step count type ***")
                    }
                    
                    // Below, we define all the quantities needed for saving to Health
                    let quantityUnit = HKUnit.gramUnit(with: .milli)
                    let quantityAmount = HKQuantity(unit: quantityUnit, doubleValue: milligram)
                    
                    let sample = HKQuantitySample(type: quantityType, quantity: quantityAmount, start: date, end: date)
                    let correlationType = HKObjectType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)
                    
                    let caffeineCorrelationForCaffeineAmount = HKCorrelation(type: correlationType!, start: date, end: date, objects: [sample])
                    
                    // Below, we save our data defined above.
                    self.healthStore.save(caffeineCorrelationForCaffeineAmount, withCompletion: { (success, error) in
                        if (error != nil) {
                            NSLog("error occured saving caffeine data")
                        }
                    })
                    
                    print("we have permission and successfully saved!")
                } else {
                    print("No HealthKit data available")
                }
            }
        }
    }
    
    // Fethces the caffeine (mg) consumed per day over the past month
    func fetchHealthData(completion: @escaping(_ caffeineRetrieved: [HKQuantitySample]) -> Void) {
        // As mentioned, this is an asynchronous call, so if you wish to use this data in your UI you should have a separate call function for the stored data that is used for UI updating.
        var typesToShare: Set<HKSampleType> {
            let caffeineType = HKObjectType.quantityType(forIdentifier: .dietaryCaffeine)!
            return [caffeineType]
        }
        
        if HKHealthStore.isHealthDataAvailable() {
            
            healthStore.requestAuthorization(toShare: [], read: typesToShare) { (success, error) in
                if success {
                    //The function HKHealthStore.isHealthDataAvailable() uses the HealthStore to check if the user has HealthKit data available. The rest of the code will run only if the data is available.
                    
                    let calendar = NSCalendar.current

                    var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: NSDate() as Date)

                    let offset = (7 + anchorComponents.weekday! - 2) % 7

                    anchorComponents.day! -= offset
                    anchorComponents.hour = 2
                    guard let anchorDate = Calendar.current.date(from: anchorComponents) else {
                        fatalError("*** unable to create a valid date from the given components ***")
                    }
                    
                    let endDate = Date()
                    guard let startDate = calendar.date(byAdding: .year, value: -1, to: endDate) else {
                        fatalError("*** Unable to calculate the start date ***")
                    }
                    let interval = NSDateComponents()
                    interval.minute = 30
                    
                    guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine) else {
                        fatalError("*** Unable to create a step count type ***")
                    }
                    
                    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictEndDate)

                    let query = HKSampleQuery(sampleType: quantityType,
                                              predicate: predicate,
                                              limit: Int(HKObjectQueryNoLimit),
                                              sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) {
                        query, results, error in
                        
                        guard let samples = results as? [HKQuantitySample] else {
                            fatalError("*** An error occurred while gathering samples: \(String(describing: error?.localizedDescription)) ***")
                        }
                        
//                        for sample in samples {
//                            sampleList.append(caffeineItem(amount: sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .milli)),
//                                              entryDate: sample.endDate))
//        //                    print(sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .milli)))
//        //                    print("\(sample.startDate) to \(sample.endDate), type \(sample.sampleType)")
//        //                    let value = quantity.doubleValue(for: HKUnit.gramUnit(with: .milli))
//                        }
                        completion(samples)
                    }
                    
                    self.healthStore.execute(query)
                    // We leave the toShare empty, as we don’t want to write anything into HealthKit. If you do want to add data into HealthKit you should define those here. Note: Some HKObjectTypes, such as the .appleStandTime can’t be edited, so if you can’t add those as the “toShare” parameters.
            } else {
                print("No HealthKit data available")
                }
            }
        }
    }
    
    func fetchAndDeleteCaffeine(sampleDate: Date) -> Bool {
        var typesToShare: Set<HKSampleType> {
            let caffeineType = HKObjectType.quantityType(forIdentifier: .dietaryCaffeine)!
            return [caffeineType]
        }
        var nonAppEntryDeleted = false
        
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: typesToShare, read: nil) { (success, error) in
                if success {
                    //Initialize the type we are saving to.
                    guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine) else {
                        fatalError("*** Unable to create a caffeine quantity type ***")
                    }
                    
                    let calendar = NSCalendar.current
                    guard let startDate = calendar.date(byAdding: .second, value: -1, to: sampleDate) else {
                        fatalError("*** Unable to calculate the start date ***")
                    }
                    guard let endDate = calendar.date(byAdding: .second, value: +1, to: sampleDate) else {
                        fatalError("*** Unable to calculate the start date ***")
                    }
                    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictEndDate)
                    
                    let query = HKSampleQuery.init(sampleType: quantityType,
                                                   predicate: predicate,
                                                   limit: HKObjectQueryNoLimit,
                                                   sortDescriptors: nil) { (query, results, error) in
                        guard let objectsToCheckDelete = results  as? [HKQuantitySample] else {
                            fatalError("*** An error occurred while gathering samples: \(String(describing: error?.localizedDescription)) ***")
                        }
                        print(objectsToCheckDelete)
                        for object in objectsToCheckDelete {
                            self.healthStore.delete(object, withCompletion: { (success, error) in
                                if !success {
                                    nonAppEntryDeleted = true
                                    print(nonAppEntryDeleted)
                                    print(error)
                                } else {
                                    print("Succesfully Deleted")
                                }
                            })
                        }
                    }
                    self.healthStore.execute(query)
                }
            }
        }
        return nonAppEntryDeleted
    }
}
