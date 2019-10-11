//
//  MockExternalObject.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync

public class MockExternalObject : HDSExternalObjectProtocol {
    public var uuid: UUID
    
    public init() {
        uuid = UUID()
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
}
