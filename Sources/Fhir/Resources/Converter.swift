//
//  Converter.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit
import HealthKitToFhir
import FHIR

open class Converter : HDSConverterProtocol {
    
    private var converterMap: [String : ResourceFactoryProtocol]
    
    public init(converterMap: [String : ResourceFactoryProtocol]) {
        self.converterMap = converterMap
    }
    
    public func convert<T>(object: HKObject) throws -> T {
        guard let t = (T.self as? Resource.Type),
            let converter = converterMap[t.resourceType] else {
                throw ConverterError.converterNotFound
        }
        
        let resource: T = try converter.resource(from: object)
        return resource
    }
    
    public func convert<T>(deletedObject: HKDeletedObject) throws -> T {
        throw ConverterError.notSupported
    }
}
