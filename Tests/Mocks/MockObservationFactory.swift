//
//  MockObservationFactory.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKitToFhir
import HealthKit
import FHIR

public class MockObservationFactory : ResourceFactoryProtocol {
    
    public static var healthKitIdentifierSystemKey = "com.apple.health"
    
    private let observationFactory = try! ObservationFactory()
    
    public var shouldThrow = false
    
    public func reset() {
        shouldThrow = false
    }
    
    open func resource<T>(from object: HKObject) throws -> T {
        
        if (shouldThrow) {
            throw MockError.decodingError
        }
        
        return try observationFactory.resource(from: object)
    }
}
