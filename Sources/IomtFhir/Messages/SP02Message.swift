//
//  SP02Message.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit

open class SP02Message : IomtFhirMessageBase, HDSExternalObjectProtocol {
    internal var sp02Count: Int16?
    internal let unit = "%/min"
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public init?(object: HKObject)
    {
        guard let sample = object as? HKQuantitySample,
            sample.quantityType == SP02Message.healthKitObjectType() else {
                return nil
        }
        
        super.init(uuid: sample.uuid, startDate: sample.startDate, endDate: sample.endDate)
        
        self.update(with: object)
        self.healthKitObject = object
    }
    
    public static func authorizationTypes() -> [HKObjectType]? {
        if let sp02Type = healthKitObjectType() {
            return [sp02Type]
        }
        
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .oxygenSaturation)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return SP02Message.init(object: object)
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return nil
    }
    
    public func update(with object: HKObject) {
        if let sample = object as? HKQuantitySample {
            sp02Count = Int16(sample.quantity.doubleValue(for: HKUnit(from: unit)))
        }
    }
    
    // Required for serialization
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sp02Count, forKey: .sp02Count)
        try container.encode(unit, forKey: .unit)
    }
    
    private enum CodingKeys: String, CodingKey {
        case sp02Count
        case unit
    }
}

