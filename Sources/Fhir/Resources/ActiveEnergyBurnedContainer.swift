//
//  ActiveEnergyBurnedContainer.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit
import FHIR

open class ActiveEnergyBurnedContainer : ResourceContainer<Observation>, HDSExternalObjectProtocol {
    internal let unit = "kcal"
    
    public static func authorizationTypes() -> [HKObjectType]? {
        if let activeEnergyBurned = healthKitObjectType() {
            return [activeEnergyBurned]
        }
        
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        if let sample = object as? HKSample,
            sample.sampleType == ActiveEnergyBurnedContainer.healthKitObjectType() {
            return ActiveEnergyBurnedContainer(object: object, converter: converter)
        }
        
        return nil
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return ActiveEnergyBurnedContainer(deletedObject: deletedObject, converter: converter)
    }
    
    public func update(with object: HKObject) {
        if let sample = object as? HKQuantitySample {
            resource?.valueQuantity?.value = FHIRDecimal(Decimal(floatLiteral: sample.quantity.doubleValue(for: HKUnit(from: unit))))
        }
    }
}
