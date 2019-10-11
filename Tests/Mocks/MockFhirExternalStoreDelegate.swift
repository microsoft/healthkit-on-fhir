//
//  MockFhirExternalStoreDelegate.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit
import FHIR

public class MockFhirExternalStoreDelegate : FhirExternalStoreDelegate {
    public var shouldFetchParams = [[HDSExternalObjectProtocol]]()
    public var shouldFetchCompletions = [(shouldFetch: Bool, error: Error?)]()
    public var fetchCompleteParams = [(objects: [HDSExternalObjectProtocol]?, success: Bool, error: Error?)]()
    public var shouldAddParams = [(resource: Resource, object: HKObject?)]()
    public var shouldAddCompletions = [(shouldAdd: Bool, error: Error?)]()
    public var addCompleteParams = [(objects: [HDSExternalObjectProtocol]?, success: Bool, error: Error?)]()
    public var shouldUpdateParams = [(resource: Resource, object: HKObject?)]()
    public var shouldUpdateCompletions = [(shouldUpdate: Bool, error: Error?)]()
    public var updateCompleteParams = [(objects: [HDSExternalObjectProtocol]?, success: Bool, error: Error?)]()
    public var shouldDeleteParams = [(resource: Resource, deletedObject: HKDeletedObject?)]()
    public var shouldDeleteCompletions = [(shouldDelete: Bool, error: Error?)]()
    public var deleteCompleteParams = [(success: Bool, error: Error?)]()
    
    public func shouldFetch(objects: [HDSExternalObjectProtocol], completion: @escaping (Bool, Error?) -> Void) {
        shouldFetchParams.append(objects)
        let comp = shouldFetchCompletions.removeFirst()
        completion(comp.shouldFetch, comp.error)
    }
    
    public func fetchComplete(objects: [HDSExternalObjectProtocol]?, success: Bool, error: Error?) {
        fetchCompleteParams.append((objects, success, error))
    }
    
    public func shouldAdd(resource: Resource, object: HKObject?, completion: @escaping (Bool, Error?) -> Void) {
        shouldAddParams.append((resource, object))
        let comp = shouldAddCompletions.removeFirst()
        completion(comp.shouldAdd, comp.error)
    }
    
    public func addComplete(objects: [HDSExternalObjectProtocol], success: Bool, error: Error?) {
        addCompleteParams.append((objects, success, error))
    }
    
    public func shouldUpdate(resource: Resource, object: HKObject?, completion: @escaping (Bool, Error?) -> Void) {
        shouldUpdateParams.append((resource, object))
        let comp = shouldUpdateCompletions.removeFirst()
        completion(comp.shouldUpdate, comp.error)
    }
    
    public func updateComplete(objects: [HDSExternalObjectProtocol], success: Bool, error: Error?) {
        updateCompleteParams.append((objects, success, error))
    }
    
    public func shouldDelete(resource: Resource, deletedObject: HKDeletedObject?, completion: @escaping (Bool, Error?) -> Void) {
        shouldDeleteParams.append((resource, deletedObject))
        let comp = shouldDeleteCompletions.removeFirst()
        completion(comp.shouldDelete, comp.error)
    }
    
    public func deleteComplete(success: Bool, error: Error?) {
        deleteCompleteParams.append((success, error))
    }
}
