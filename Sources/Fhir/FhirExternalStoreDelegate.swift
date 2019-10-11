//
//  FhirExternalStoreDelegate.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import FHIR
import HealthDataSync

public protocol FhirExternalStoreDelegate {
    
    /// Called after a HealthKit query has completed but before the data is fetched from the FHIR server.
    ///
    /// - Parameters:
    ///   - objects: The collection of HDSExternalObjectProtocol objects used to fetch resources from the Server.
    ///   - completion: MUST be called to start the fetch of the FHIR.Resources. Return true to start the fetch process and false to cancel. Optional Error will be passed to the FhirExternalStore.
    func shouldFetch(objects: [HDSExternalObjectProtocol], completion: @escaping (Bool, Error?) -> Void)
    
    /// Called after all data is fetched from the FHIR Server.
    ///
    /// - Parameters:
    ///   - objects: The collection of HDSExternalObjectProtocol objects used to fetch resources from the Server.
    ///   - success: Bool representing whether or not the request was successful.
    ///   - error: An Error with detail about the failure (will be nil if the operation was successful).
    func fetchComplete(objects: [HDSExternalObjectProtocol]?, success: Bool, error: Error?)
    
    /// Called after a HealthKit query has completed but before the data is sent to the FHIR server.
    ///
    /// - Parameters:
    ///   - resource: The FHIR.Resource object to be sent.
    ///   - object: The original underlying HealthKit HKObject.
    ///   - completion: MUST be called to start the upload of the FHIR.Resource. Return true to start the upload and false to cancel. Optional Error will be passed to the FhirExternalStore.
    func shouldAdd(resource: Resource, object: HKObject?, completion: @escaping (Bool, Error?) -> Void)
    
    /// Called after all data is sent to the FHIR Server.
    ///
    /// - Parameters:
    ///   - objects: The collection of HDSExternalObjectProtocol objects used to add resources to the Server.
    ///   - success: Bool representing whether or not the request was successful.
    ///   - error: An Error with detail about the failure (will be nil if the operation was successful).
    func addComplete(objects: [HDSExternalObjectProtocol], success: Bool, error: Error?)
    
    /// Called after a HealthKit query has completed but before the data is updated in the FHIR server.
    ///
    /// - Parameters:
    ///   - resource: The FHIR.Resource object to be updated.
    ///   - object: The original underlying HealthKit HKObject.
    ///   - completion: MUST be called to initiate the update on the FHIR.Resource. Return true to start the update request and false to cancel. Optional Error will be passed to the FhirExternalStore.
    func shouldUpdate(resource: Resource, object: HKObject?, completion: @escaping (Bool, Error?) -> Void)
    
    /// Called after all data is updated on the FHIR Server.
    ///
    /// - Parameters:
    ///   - containers: The collection of HDSExternalObjectProtocol objects used to update resources on the Server.
    ///   - success: Bool representing whether or not the request was successful.
    ///   - error: An Error with detail about the failure (will be nil if the operation was successful).
    func updateComplete(objects: [HDSExternalObjectProtocol], success: Bool, error: Error?)
    
    /// Called after a HealthKit query has completed but before the delete request is sent the FHIR server.
    ///
    /// - Parameters:
    ///   - resource: The FHIR.Resource object to be deleted.
    ///   - object: The HealthKit HKDeletedObject.
    ///   - completion: MUST be called to initiate the deletion of the FHIR.Resource. Return true to delete and false to cancel. Optional Error will be passed to the FhirExternalStore.
    func shouldDelete(resource: Resource, deletedObject: HKDeletedObject?, completion: @escaping (Bool, Error?) -> Void)
    
    /// Called after all deletes are completed on the FHIR Server.
    ///
    /// - Parameters:
    ///   - success: Bool representing whether or not the request was successful.
    ///   - error: An Error with detail about the failure (will be nil if the operation was successful).
    func deleteComplete(success: Bool, error: Error?)
}

public extension FhirExternalStoreDelegate
{
    func shouldFetch(objects: [HDSExternalObjectProtocol], completion: @escaping (Bool, Error?) -> Void) {
        completion(true, nil)
    }

    func fetchComplete(objects: [HDSExternalObjectProtocol]?, success: Bool, error: Error?) {
        
    }

    func shouldAdd(resource: Resource, object: HKObject?, completion: @escaping (Bool, Error?) -> Void) {
        completion(true, nil)
    }

    func addComplete(objects: [HDSExternalObjectProtocol], success: Bool, error: Error?) {
        
    }
    
    func shouldUpdate(resource: Resource, object: HKObject?, completion: @escaping (Bool, Error?) -> Void) {
        completion(true, nil)
    }
    
    func updateComplete(objects: [HDSExternalObjectProtocol], success: Bool, error: Error?) {
        
    }
    
    func shouldDelete(resource: Resource, deletedObject: HKDeletedObject?, completion: @escaping (Bool, Error?) -> Void) {
        completion(true, nil)
    }

    func deleteComplete(success: Bool, error: Error?) {
        
    }
}
