//
//  ResourceContainerProtocol.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import FHIR

public protocol ResourceContainerProtocol {
    
    /// The type of FHIR.Resource in the container.
    var resourceType: Resource.Type { get }
    
    /// The underlying HealthKit object used to create the resource object
    var healthKitObject: HKObject? { get }
    
    /// The underlying HealthKit object used to create the resource object
    var healthKitDeletedObject: HKDeletedObject? { get }
    
    /// The underlying HKObject UUID
    var uuid: UUID { get }
    
    /// Gets the FHIR.Resource from the resource container.
    ///
    /// - Returns: A FHIR.Resource object
    /// - Throws: Throws if the resource creation process fails.
    func getResource() throws -> Resource
    
    /// Sets a FHIR.Resource to the resource container
    ///
    /// - Parameter resource: The FHIR.Resource to be set.
    func setResource(resource: Resource)
}
