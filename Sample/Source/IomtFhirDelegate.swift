//
//  IomtFhirDelegate.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import IomtFhirClient
import HealthKit
import HealthKitOnFhir
import HealthKitToFhir
import SMART

public class IomtFhirDelegate : ExternalStoreDelegate, IomtFhirExternalStoreDelegate {
    
    public func shouldAdd(eventData: EventData, object: HKObject?, completion: @escaping (Bool, Error?) -> Void) {
        // Get the patient id and device id from the FHIR server
        getPatientAndDeviceIds(object: object) { (patientId, deviceIdentifier, deviceId, error) in
            // Ensure there is no error
            guard error == nil else {
                completion(false, error)
                return
            }
            
            do {
                if var dictionary = try JSONSerialization.jsonObject(with: eventData.data, options: .mutableContainers) as? [String : Any] {
                    // Add the patient and device ids (which should be mapped in FHIR)
                    dictionary["patientId"] = patientId
                    dictionary["deviceId"] = deviceIdentifier
                    eventData.data = try JSONSerialization.data(withJSONObject: dictionary, options: .sortedKeys)
                    
                    completion(true, nil)
                } else {
                    completion(false, ExternalStoreDelegateError.eventDataSerializationError)
                }
            } catch {
                completion(false, error)
            }
        }
    }
    
    public func addComplete(eventDatas: [EventData], success: Bool, error: Error?) {
        if !success,
            error != nil {
            print(error!)
        }
        
        print("Send Completed. eventDatas count = \(eventDatas.count)")
    }
}
