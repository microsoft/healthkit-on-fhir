//
//  OxygenSaturationContainer.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit
import HealthKitToFhir
import FHIR

open class OxygenSaturationContainer : ResourceContainer<Observation>, HDSExternalObjectProtocol {
    internal let unit = "%"
    
    public static func authorizationTypes() -> [HKObjectType]? {
        if let oxygenSaturationType = healthKitObjectType() {
            return [oxygenSaturationType]
        }
        
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .oxygenSaturation)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        if let sample = object as? HKSample,
            sample.sampleType == OxygenSaturationContainer.healthKitObjectType() {
            return OxygenSaturationContainer(object: object, converter: converter)
        }
        
        return nil
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return OxygenSaturationContainer(deletedObject: deletedObject, converter: converter)
    }
    
    public func update(with object: HKObject) {
        if let sample = object as? HKQuantitySample {
            resource?.valueQuantity?.value = FHIRDecimal(Decimal(floatLiteral: sample.quantity.doubleValue(for: HKUnit(from: unit))))
        }
    }
}
