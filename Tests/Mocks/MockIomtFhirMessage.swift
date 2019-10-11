//
//  MockIomtFhirMessage.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit

public class MockIomtFhirMessage : IomtFhirMessageBase, HDSExternalObjectProtocol {
    public var value: Double?
    public var shouldThrowOnDecode = false
    
    public init() {
        super.init(uuid: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, startDate: Date.init(timeIntervalSince1970: 0), endDate: Date.init(timeIntervalSince1970: 0))
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public static func authorizationTypes() -> [HKObjectType]? {
        return nil
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return nil
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return nil
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        return nil
    }
    
    public func update(with object: HKObject) {
    }
    
    // Required for serializaion
    public override func encode(to encoder: Encoder) throws {
        if shouldThrowOnDecode {
            throw MockError.decodingError
        }
        
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
    
    private enum CodingKeys: String, CodingKey {
        case value
    }
}
