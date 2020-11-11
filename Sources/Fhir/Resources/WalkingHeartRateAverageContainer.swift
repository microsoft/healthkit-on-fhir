//
//  WalkingHeartRateAverageContainer.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit
import FHIR

open class WalkingHeartRateAverageContainer : ResourceContainer<Observation>, HDSExternalObjectProtocol {
    internal let unit = "count/min"
    
    public static func authorizationTypes() -> [HKObjectType]? {
        if let walkingHeartRateAverage = healthKitObjectType() {
            return [walkingHeartRateAverage]
        }
        
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        if let sample = object as? HKSample,
            sample.sampleType == WalkingHeartRateAverageContainer.healthKitObjectType() {
            return WalkingHeartRateAverageContainer(object: object, converter: converter)
        }
        
        return nil
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return WalkingHeartRateAverageContainer(deletedObject: deletedObject, converter: converter)
    }
    
    public func update(with object: HKObject) {
        if let sample = object as? HKQuantitySample {
            resource?.valueQuantity?.value = FHIRDecimal(Decimal(floatLiteral: sample.quantity.doubleValue(for: HKUnit(from: unit))))
        }
    }
}
