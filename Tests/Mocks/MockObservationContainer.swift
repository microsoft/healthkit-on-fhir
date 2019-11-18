//
//  MockObservationContainer.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit
import FHIR

public class MockObservationContainer : ResourceContainer<Observation>, HDSExternalObjectProtocol {
    public static func authorizationTypes() -> [HKObjectType]? {
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return nil
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return MockObservationContainer(object: object, converter: converter)
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return MockObservationContainer(deletedObject: deletedObject, converter: converter)
    }
    
    public func update(with object: HKObject) {
        
    }
}
