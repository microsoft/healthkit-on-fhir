//
//  IomtFhirExternalStoreDelegate.swift
//  AFNetworking
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import IomtFhirClient

public protocol IomtFhirExternalStoreDelegate {
    
    /// Called once for each EventData after a HealthKit query has completed but before the data is sent to the the Iomt Fhir Connector for Azure.
    ///
    /// - Parameters:
    ///   - eventData: The EventData object to be sent.
    ///   - object: The original underlying HealthKit HKObject.
    ///   - completion: Must be called to start the upload of the EventData. Return true to start the upload and false to cancel. Optional Error will be passed to the IomtFhirExternalStore.
    func shouldAdd(eventData: EventData, object: HKObject?, completion: @escaping (Bool, Error?) -> Void)
    
    /// Called after ALL data is sent to the the Iomt Fhir Connector for Azure.
    ///
    /// - Parameters:
    ///   - eventDatas: The EventData that was sent to the the Iomt Fhir Connector for Azure.
    ///   - success: Bool representing whether or not the request was successful.
    ///   - error: An Error with detail about the failure (will be nil if the operation was successful).
    func addComplete(eventDatas: [EventData], success: Bool, error: Error?)
}

public extension IomtFhirExternalStoreDelegate
{
    func shouldAdd(eventData: EventData, object: HKObject?, completion: @escaping (Bool, Error?) -> Void) {
        completion(true, nil)
    }
    
    func addComplete(eventDatas: [EventData], success: Bool, error: Error?) {
        
    }
}
