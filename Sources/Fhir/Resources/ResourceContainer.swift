//
//  ResourceContainer.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit
import FHIR
import HealthKitToFhir

open class ResourceContainer<T: Resource> : ResourceContainerProtocol {
    
    public private(set) var resourceType: Resource.Type = T.self
    
    public private(set) var healthKitObject: HKObject?
    
    public private(set) var healthKitDeletedObject: HKDeletedObject?

    public var uuid: UUID
    
    internal var resource: T?
    internal let converter: HDSConverterProtocol?
    
    public init(object: HKObject, converter: HDSConverterProtocol?) {
        healthKitObject = object
        uuid = object.uuid
        self.converter = converter
    }
    
    public init(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) {
        healthKitDeletedObject = deletedObject
        uuid = deletedObject.uuid
        self.converter = converter
    }
    
    public func getResource() throws -> Resource {
        if resource == nil {
            guard converter != nil else {
                throw ConverterError.requiredConverterNotProvided
            }
            
            guard healthKitObject != nil else {
                throw ConverterError.noObjectToConvert
            }
            
            let value: T = try converter!.convert(object: healthKitObject!)
            resource = value
        }
        
        return resource!
    }
    
    public func setResource(resource: Resource) {
        self.resource = resource as? T
    }
}
