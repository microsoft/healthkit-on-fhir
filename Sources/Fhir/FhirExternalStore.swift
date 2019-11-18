//
//  FhirExternalStore.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync
import FHIR
import HealthKitToFhir

open class FhirExternalStore : HDSExternalStoreProtocol {
    public var delegate: FhirExternalStoreDelegate?
    
    private static let fetchBatchSize = 10
    
    // Dependencies
    private let server: FHIRServer
    
    required public init(server: FHIRServer)
    {
        self.server = server
    }
    
    public func fetchObjects(with objects: [HDSExternalObjectProtocol], completion: @escaping ([HDSExternalObjectProtocol]?, Error?) -> Void) {
        // Nothing to fetch - complete and return.
        guard objects.count > 0 else {
            completion(nil, nil)
            return
        }
        
        guard delegate != nil else {
            search(searchObjects: objects, results: [HDSExternalObjectProtocol](), index: 0, completion: completion)
            return
        }
        
        delegate?.shouldFetch(objects: objects, completion: { (shouldFetch, error) in
            guard shouldFetch else {
                self.delegate?.fetchComplete(objects: nil, success: error == nil, error: error)
                completion(nil, error)
                return
            }
            
            self.search(searchObjects: objects, results: [HDSExternalObjectProtocol](), index: 0, completion: { (externalObjects, error) in
                self.delegate?.fetchComplete(objects: externalObjects, success: error == nil, error: error)
                completion(externalObjects, error)
            })
        })
    }
    
    public func add(objects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void) {
        // Nothing to sync - complete and return.
        guard objects.count > 0 else {
            completion(nil)
            return
        }
        
        perform(method:.POST, objects: objects, index: 0, completion: { (error) in
            self.delegate?.addComplete(objects: objects, success: error == nil, error: error)
            completion(error)
        })
    }
    
    public func update(objects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void) {
        // Nothing to update - complete and return.
        guard objects.count > 0 else {
            completion(nil)
            return
        }
        
        perform(method:.PUT, objects: objects, index: 0, completion: { (error) in
            self.delegate?.updateComplete(objects: objects, success: error == nil, error: error)
            completion(error)
        })
    }
    
    public func delete(deletedObjects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void) {
        // Nothing to delete - complete and return.
        guard deletedObjects.count > 0 else {
            completion(nil)
            return
        }
        
        perform(method:.DELETE, objects: deletedObjects, index: 0, completion: { (error) in
            self.delegate?.deleteComplete(success: error == nil, error: error)
            completion(error)
        })
    }
    
    private func search(searchObjects: [HDSExternalObjectProtocol], results: [HDSExternalObjectProtocol], index: Int, completion: @escaping ([HDSExternalObjectProtocol]?, Error?) -> Void) {
        if searchObjects.count == index {
            completion(results, nil)
            return
        }
        
        guard let type = (searchObjects[index] as? ResourceContainerProtocol)?.resourceType else {
            completion(nil, FetchError.invalidResourceType)
            return
        }
        
        var count = index
        var searchParams = "\(FactoryBase.healthKitIdentifierSystemKey)|"
        
        while count < searchObjects.count && count < index + FhirExternalStore.fetchBatchSize {
            // Ensure all search ids the same type of resource as the first in the collection.
            guard let container = searchObjects[count] as? ResourceContainerProtocol,
                type == container.resourceType else {
                    completion(nil, FetchError.resourceTypeMismatch)
                    return
                }
                
            searchParams.append("\(container.uuid.uuidString),")
            count += 1
        }
        
        // Remove the trailing comma.
        searchParams.removeLast()
        
        // Perform the search.
        let search = type.search(["identifier" : searchParams])
        search.performAndContinue(server, pageLimit: FhirExternalStore.fetchBatchSize) { (bundle, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            var mutableResults = results
            
            do {
                // Find any matching entries in the bundle, set the corresponding container resource property and add it to the results collection.
                let objects: [HDSExternalObjectProtocol] = try searchObjects[index..<count].compactMap({
                    if let container = $0 as? ResourceContainerProtocol,
                        let resource = try bundle?.resourceWithIdentifier(system: FactoryBase.healthKitIdentifierSystemKey, value: container.uuid.uuidString) {
                        container.setResource(resource: resource)
                        return container as? HDSExternalObjectProtocol
                    }
                    return nil
                })
                
                mutableResults.append(contentsOf: objects)
                
            } catch {
                completion(nil, error)
                return
            }
            
            self.search(searchObjects: searchObjects, results: mutableResults, index: count, completion: completion)
        }
    }
    
    private func perform(method: FHIRRequestMethod, objects: [HDSExternalObjectProtocol], index: Int, completion: @escaping (Error?) -> Void) {
        if objects.count == index {
            completion(nil)
            return
        }
        
        // Ensure the object conforms to ResourceContainerProtocol
        if let container = objects[index] as? ResourceContainerProtocol {
            do {
                // Create an observation for each sample.
                let resource = try container.getResource()
                
                // Create a handler for the given method and resource.
                guard let handler = server.handlerForRequest(withMethod: method, resource: method == .DELETE ? nil : resource) else {
                    completion(FHIRError.noRequestHandlerAvailable(method))
                    return
                }
                
                // Ensure that POST request resources do not contain an Id.
                if method == .POST {
                    guard nil == resource.id else {
                        completion(FHIRError.resourceAlreadyHasId)
                        return
                    }
                }
                
                // Get the appropriate path for the resource.
                let path = method == .POST ? resource.relativeURLBase() : try resource.relativeURLPath()
                
                // Check the delegate if the pending operation should be executed.
                self.shouldPerform(method: method, resource: resource, object: container.healthKitObject, deletedObject: container.healthKitDeletedObject, completion: { (shouldPerform, error) in
                    guard shouldPerform else {
                        completion(error)
                        return
                    }
                    
                    self.server.performRequest(against: path, handler: handler) { (response) in
                        guard response.error == nil else {
                            completion(response.error)
                            return
                        }
                        
                        self.perform(method:method, objects: objects, index: index + 1, completion: completion)
                    }
                })
                
            } catch {
                completion(error)
            }
        } else {
            self.perform(method:method, objects: objects, index: index + 1, completion: completion)
        }
    }
    
    private func shouldPerform(method: FHIRRequestMethod, resource: Resource, object: HKObject?, deletedObject: HKDeletedObject?, completion: @escaping (Bool, Error?) -> Void) {
        guard delegate != nil else {
            completion(true, nil)
            return
        }
        
        switch method {
        case .POST:
            self.delegate?.shouldAdd(resource: resource, object: object, completion: completion)
            break
        case .PUT:
            self.delegate?.shouldUpdate(resource: resource, object: object, completion: completion)
            break
        case .DELETE:
            self.delegate?.shouldDelete(resource: resource, deletedObject: deletedObject, completion: completion)
            break
        default:
            completion(true, nil)
        }
    }
}
