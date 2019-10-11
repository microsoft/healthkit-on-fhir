//
//  QueryObserverDelegate.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync

public class QueryObserverDelegate : HDSQueryObserverDelegate {
    
    public static let observerUpdated = Notification.Name("QueryObserverUpdated")
    
    public func shouldExecute(for observer: HDSQueryObserver, completion: @escaping (Bool) -> Void) {
        // If an observer has never run before, we limit the number of "historical" samples to prevent memory exceptions.
        // The number of samples could represent years of data.
        if observer.lastSuccessfulExecutionDate == nil {
            // Get a date object set to the start of today.
            let now = Date()
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: now)
            
            // Limit the query to samples starting from midnight of today.
            observer.queryPredicate = HKQuery.predicateForSamples(withStart: startOfToday, end: nil, options: HKQueryOptions.strictStartDate)
        }
        
        completion(true)
    }
    
    public func didFinishExecution(for observer: HDSQueryObserver, error: Error?) {
        // Post a notification that the observer has finished executing.
        NotificationCenter.default.post(name: QueryObserverDelegate.observerUpdated, object: observer)
    }
}
