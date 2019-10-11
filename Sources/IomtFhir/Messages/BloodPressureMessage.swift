//
//  BloodPressureMessage.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit

public class BloodPressureMessage : IomtFhirMessageBase, HDSExternalObjectProtocol {
    internal var systolic: Double?
    internal var diastolic: Double?
    internal let systolicUnit = "mmHg"
    internal let diastolicUnit = "mmHg"
    
    public init?(object: HKObject)
    {
        guard let correlation = object as? HKCorrelation,
            correlation.correlationType == BloodPressureMessage.healthKitObjectType() else {
                return nil
        }
        
        super.init(uuid: correlation.uuid, startDate: correlation.startDate, endDate: correlation.endDate)
        
        self.update(with: object)
        self.healthKitObject = object
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
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
        return BloodPressureMessage.init(object: object)
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return nil
    }
    
    public func update(with object: HKObject) {
        if let correlation = object as? HKCorrelation,
            let systolicSample = correlation.objects(for: HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!).first as? HKQuantitySample,
            let diastolicSample = correlation.objects(for: HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!).first as? HKQuantitySample {
            systolic = systolicSample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
            diastolic = diastolicSample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
        }
    }
    
    // Required for serializaion
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(systolic, forKey: .systolic)
        try container.encode(diastolic, forKey: .diastolic)
        try container.encode(systolicUnit, forKey: .systolicUnit)
        try container.encode(diastolicUnit, forKey: .diastolicUnit)
    }
    
    private enum CodingKeys: String, CodingKey {
        case systolic
        case diastolic
        case systolicUnit
        case diastolicUnit
    }
}
