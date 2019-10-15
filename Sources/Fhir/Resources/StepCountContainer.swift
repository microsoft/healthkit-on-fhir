//
//  StepCountContainer.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit
import FHIR

open class StepCountContainer : ResourceContainer<Observation>, HDSExternalObjectProtocol {
    internal let unit = "count"
    
    public static func authorizationTypes() -> [HKObjectType]? {
        if let stepCountType = healthKitObjectType() {
            return [stepCountType]
        }
        
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .stepCount)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        if let sample = object as? HKSample,
            sample.sampleType == StepCountContainer.healthKitObjectType() {
            return StepCountContainer(object: object, converter: converter)
        }
        
        return nil
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return StepCountContainer(deletedObject: deletedObject, converter: converter)
    }
    
    public func update(with object: HKObject) {
        if let sample = object as? HKQuantitySample {
            resource?.valueQuantity?.value = FHIRDecimal(Decimal(floatLiteral: sample.quantity.doubleValue(for: HKUnit(from: unit))))
        }
    }
}

