//
//  BloodPressureContainer.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import FHIR
import HealthDataSync
import HealthKit

public class BloodPressureContainer : ResourceContainer<Observation>, HDSExternalObjectProtocol {
    internal let systolicUnit = "mmHg"
    internal let diastolicUnit = "mmHg"
    
    public static func authorizationTypes() -> [HKObjectType]? {
        if let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
            let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic) {
            return [systolicType, diastolicType]
        }
        
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.correlationType(forIdentifier: .bloodPressure)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        if let sample = object as? HKSample,
            sample.sampleType == BloodPressureContainer.healthKitObjectType() {
            return BloodPressureContainer(object: object, converter: converter)
        }
        
        return nil
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return BloodPressureContainer(deletedObject: deletedObject, converter: converter)
    }
    
    public func update(with object: HKObject) {
        do {
            if let converter = self.converter {
                let value: Observation = try converter.convert(object: healthKitObject!)
                resource?.component = value.component
            }
        } catch {
            print(error)
        }
    }
}
