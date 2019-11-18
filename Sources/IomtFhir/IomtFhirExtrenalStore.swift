//
//  IomtFhirExternalStore.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync
import IomtFhirClient

/// An implemtation of the HDSExternalStoreProtocol used to store high frequency HealthKit data into a FHIR Server.
open class IomtFhirExternalStore : HDSExternalStoreProtocol
{
    public var delegate: IomtFhirExternalStoreDelegate?
    
    private let iomtFhirClient: IomtFhirClient
    
    required public init(iomtFhirClient: IomtFhirClient)
    {
        self.iomtFhirClient = iomtFhirClient
    }
    
    public func fetchObjects(with objects: [HDSExternalObjectProtocol], completion: @escaping ([HDSExternalObjectProtocol]? , Error?) -> Void) {
        // Fetching is not supported by the the Iomt Fhir Connector for Azure.
        completion(nil, nil)
    }
    
    public func add(objects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void) {
        // Nothing to sync - complete and return.
        guard objects.count > 0 else {
            completion(nil)
            return
        }
        
        // Create a new event data array
        let eventDatas: [EventData] = []
        
        createEventDatas(objects: objects, eventDatas: eventDatas, index: 0) { (datas, error) in
            do {
                guard error == nil else {
                    throw error!
                }
                // Send the data to the Iomt Fhir Connector for Azure.
                try self.iomtFhirClient.send(eventDatas: datas) { (success, error) in
                    // Notify the delegate that the send operation has completed and call the completion passed into the add function.
                    self.delegate?.addComplete(eventDatas: datas, success: success, error: error)
                    completion(error)
                }
            } catch {
                // Notify the delegate that the send operation has failed and call the completion passed into the add function..
                self.delegate?.addComplete(eventDatas: datas, success: false, error: error)
                completion(error)
            }
        }
    }
    
    public func update(objects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void) {
        // Updates are not supported by the the Iomt Fhir Connector for Azure.
        completion(nil)
    }
    
    public func delete(deletedObjects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void) {
        // Delete is not supported by the the Iomt Fhir Connector for Azure.
        completion(nil)
    }
    
    private func createEventDatas(objects: [HDSExternalObjectProtocol], eventDatas:[EventData], index: Int, completion: @escaping ([EventData], Error?) -> Void) {
        if objects.count == index {
            completion(eventDatas, nil)
            return
        }
        
        if let message = objects[index] as? IomtFhirMessageBase {
            do {
                // Generate event data for each message.
                let eventData = try message.generateEventData()
                var mutableEventDatas = eventDatas
                
                guard delegate != nil else {
                    // No delegate - Just add the EventData to the payload and continue recursion.
                    mutableEventDatas.append(eventData)
                    self.createEventDatas(objects: objects, eventDatas: mutableEventDatas, index: index + 1, completion: completion)
                    return
                }
                
                // Check the delegate if the pending add operation should be executed.
                delegate?.shouldAdd(eventData: eventData, object: message.healthKitObject, completion: { (shouldAdd, error) in
                    guard shouldAdd else {
                        completion(eventDatas, error)
                        return
                    }
                    
                    // Add the EventData to the payload.
                    mutableEventDatas.append(eventData)
                    self.createEventDatas(objects: objects, eventDatas: mutableEventDatas, index: index + 1, completion: completion)
                })
                
            } catch {
                completion(eventDatas, error)
            }
        } else {
            self.createEventDatas(objects: objects, eventDatas: eventDatas, index: index + 1, completion: completion)
        }
    }
}
