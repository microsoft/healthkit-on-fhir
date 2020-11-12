//
//  DietaryEnergyConsumedContainer.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit
import FHIR

open class DietaryEnergyConsumedContainer : ResourceContainer<Observation>, HDSExternalObjectProtocol {
    internal let unit = "kcal"
    
    public static func authorizationTypes() -> [HKObjectType]? {
        if let dietaryEnergyConsumed = healthKitObjectType() {
            return [dietaryEnergyConsumed]
        }
        
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        if let sample = object as? HKSample,
            sample.sampleType == DietaryEnergyConsumedContainer.healthKitObjectType() {
            return DietaryEnergyConsumedContainer(object: object, converter: converter)
        }
        
        return nil
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return DietaryEnergyConsumedContainer(deletedObject: deletedObject, converter: converter)
    }
    
    public func update(with object: HKObject) {
        if let sample = object as? HKQuantitySample {
            resource?.valueQuantity?.value = FHIRDecimal(Decimal(floatLiteral: sample.quantity.doubleValue(for: HKUnit(from: unit))))
        }
    }
}
