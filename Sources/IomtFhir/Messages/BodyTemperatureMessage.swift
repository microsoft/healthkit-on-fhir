//
//  BodyTemperatureMessage.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit

open class BodyTemperatureMessage : IomtFhirMessageBase, HDSExternalObjectProtocol {
    internal var bodyTemperature: Double?
    internal let unit = "degC"
    
    public init?(object: HKObject) {
        guard let sample = object as? HKQuantitySample,
            sample.quantityType == BodyTemperatureMessage.healthKitObjectType() else {
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
        if let bodyTemperatureType = healthKitObjectType() {
            return [bodyTemperatureType]
        }
        
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .bodyTemperature)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return BodyTemperatureMessage.init(object: object)
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return nil
    }
    
    public func update(with object: HKObject) {
        if let sample = object as? HKQuantitySample {
            bodyTemperature = sample.quantity.doubleValue(for: HKUnit(from: unit))
        }
    }
    
    // Required for serialization.
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bodyTemperature, forKey: .bodyTemperature)
        try container.encode(unit, forKey: .unit)
    }
    
    private enum CodingKeys: String, CodingKey {
        case bodyTemperature
        case unit
    }
}
