//
//  MockExternalStoreDelegate.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import IomtFhirClient

public class MockExternalStoreDelegate : IomtFhirExternalStoreDelegate {
    public var shouldAddCompletionValue: (Bool, Error?) = (true, nil)
    public var shouldAddParams: (EventData, HKObject?)?
    public var addCompleteParams: ([EventData], Bool, Error?)?
    
    public func shouldAdd(eventData: EventData, object: HKObject?, completion: @escaping (Bool, Error?) -> Void) {
        shouldAddParams = (eventData, object)
        completion(shouldAddCompletionValue.0, shouldAddCompletionValue.1)
    }
    
    public func addComplete(eventDatas: [EventData], success: Bool, error: Error?) {
        addCompleteParams = (eventDatas, success, error)
    }
}
