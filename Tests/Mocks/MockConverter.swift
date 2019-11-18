//
//  MockConverter.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync

public class MockConverter : HDSConverterProtocol {
    public var convertObjectsParams = [HKObject]()
    public var convertObjectReturns = [Any]()
    public var convertDeletedObjectsParams = [HKDeletedObject]()
    public var convertDeletedObjectReturns = [Any]()
    
    public func convert<T>(object: HKObject) throws -> T {
        convertObjectsParams.append(object)
        let retval = convertObjectReturns.removeFirst()
        if let error = retval as? Error {
            throw error
        }
        return retval as! T
    }
    
    public func convert<T>(deletedObject: HKDeletedObject) throws -> T {
        convertDeletedObjectsParams.append(deletedObject)
        let retval = convertDeletedObjectReturns.removeFirst()
        if let error = retval as? Error {
            throw error
        }
        return retval as! T
    }
}
