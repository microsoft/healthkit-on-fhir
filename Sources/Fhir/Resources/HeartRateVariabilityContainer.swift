//
//  HeartRateVariabilityContainer.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit
import FHIR

open class HeartRateVariabilityContainer : ResourceContainer<Observation>, HDSExternalObjectProtocol {
    internal let unit = "ms"
    
    public static func authorizationTypes() -> [HKObjectType]? {
        if let heartRateVariability = healthKitObjectType() {
            return [heartRateVariability]
        }
        
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        if let sample = object as? HKSample,
            sample.sampleType == HeartRateVariabilityContainer.healthKitObjectType() {
            return HeartRateVariabilityContainer(object: object, converter: converter)
        }
        
        return nil
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return HeartRateVariabilityContainer(deletedObject: deletedObject, converter: converter)
    }
    
    public func update(with object: HKObject) {
        if let sample = object as? HKQuantitySample {
            resource?.valueQuantity?.value = FHIRDecimal(Decimal(floatLiteral: sample.quantity.doubleValue(for: HKUnit(from: unit))))
        }
    }
}
