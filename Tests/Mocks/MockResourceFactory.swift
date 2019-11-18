//
//  MockResourceFactory.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKitToFhir
import HealthKit

public class MockResourceFactory : ResourceFactoryProtocol {
    public static var healthKitIdentifierSystemKey = "com.apple.health"
    
    public var resourceParams = [HKObject]()
    public var resourceReturns = [Any]()
    
    public func resource<T>(from object: HKObject) throws -> T {
        resourceParams.append(object)
        let retval = resourceReturns.removeFirst()
        if let error = retval as? Error {
            throw error
        }
        return retval as! T
    }
}
