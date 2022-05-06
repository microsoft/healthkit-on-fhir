//
//  OxygenSaturationMessage.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit

open class OxygenSaturationMessage : IomtFhirMessageBase, HDSExternalObjectProtocol {
    internal var spO2Count: Int16?
    internal let unit = "%"
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public init?(object: HKObject)
    {
        guard let sample = object as? HKQuantitySample,
            sample.quantityType == OxygenSaturationMessage.healthKitObjectType() else {
                return nil
        }
        
        super.init(uuid: sample.uuid, startDate: sample.startDate, endDate: sample.endDate)
        
        self.update(with: object)
        self.healthKitObject = object
    }
    
    public static func authorizationTypes() -> [HKObjectType]? {
        if let spO2Type = healthKitObjectType() {
            return [spO2Type]
        }
        
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .oxygenSaturation)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return OxygenSaturationMessage.init(object: object)
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return nil
    }
    
    public func update(with object: HKObject) {
        if let sample = object as? HKQuantitySample {
            spO2Count = Int16(sample.quantity.doubleValue(for: HKUnit(from: unit)))
        }
    }
    
    // Required for serialization
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(spO2Count, forKey: .spO2Count)
        try container.encode(unit, forKey: .unit)
    }
    
    private enum CodingKeys: String, CodingKey {
        case spO2Count
        case unit
    }
}

