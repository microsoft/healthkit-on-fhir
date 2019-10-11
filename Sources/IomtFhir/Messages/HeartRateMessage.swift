//
//  HeartRateMessage.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit

public class HeartRateMessage : IomtFhirMessageBase, HDSExternalObjectProtocol {
    internal var heartRate: Double?
    internal let unit = "beats/min"
    internal let healthKitUnit = "count/min"
    
    public init?(object: HKObject) {
        guard let sample = object as? HKQuantitySample,
            sample.quantityType == HeartRateMessage.healthKitObjectType() else {
            return nil
        }
        
        super.init(uuid: sample.uuid, startDate: sample.startDate, endDate: sample.endDate)
        
        self.update(with: object)
        self.healthKitObject = object
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public static func authorizationTypes() -> [HKObjectType]? {
        if let heartRateType = healthKitObjectType() {
            return [heartRateType]
        }
        
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .heartRate)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return HeartRateMessage.init(object: object)
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return nil
    }
    
    public func update(with object: HKObject) {
        if let sample = object as? HKQuantitySample {
            heartRate = sample.quantity.doubleValue(for: HKUnit(from: healthKitUnit))
        }
    }
    
    // Required for serializaion
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(heartRate, forKey: .heartRate)
        try container.encode(unit, forKey: .unit)
    }
    
    private enum CodingKeys: String, CodingKey {
        case heartRate
        case unit
    }
}
