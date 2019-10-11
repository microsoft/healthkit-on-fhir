//
//  FhirDelegate.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync
import HealthKitOnFhir
import SMART

public class FhirDelegate : ExternalStoreDelegate, FhirExternalStoreDelegate {
    
    public func shouldFetch(objects: [HDSExternalObjectProtocol], completion: @escaping (Bool, Error?) -> Void) {
        smartClient.authorize { (patient, error) in
            completion(error == nil, error)
        }
    }
    
    public func fetchComplete(objects: [HDSExternalObjectProtocol], success: Bool, error: Error?) {
        print("fetch completed \(error != nil ? error!.localizedDescription : "")")
    }
    
    public func shouldAdd(resource: Resource, object: HKObject?, completion: @escaping (Bool, Error?) -> Void) {
        guard let observation = resource as? Observation else {
            completion(true, nil)
            return
        }
        
        // Ensure the token is valid
        smartClient.authorize { (patient, error) in
            guard error == nil else {
                completion(false, error)
                return
            }
         
            // For observation types set the patient id and device id on the resource.
            self.getPatientAndDeviceIds(object: object) { (patientId, sourceRevisionId, deviceId, error) in
                // Ensure there is no error and that the device id and patient id are not nil.
                guard error == nil,
                    patientId != nil,
                    deviceId != nil else {
                        completion(false, error)
                        return
                }
                
                do {
                    let patientReference = try Reference(json: ["reference" : "Patient/\(patientId!)"])
                    let deviceReference = try Reference(json: ["reference" : "Device/\(deviceId!)"])
                    observation.subject = patientReference
                    observation.device = deviceReference
                    
                    // Finalize the observation
                    observation.status = .final
                    
                    completion(true, nil)
                } catch {
                    completion(false, error)
                }
            }
        }
    }
    
    public func addComplete(objects: [HDSExternalObjectProtocol], success: Bool, error: Error?) {
        print("Add completed \(error != nil ? error!.localizedDescription : "")")
    }

    public func shouldUpdate(resource: Resource, object: HKObject?, completion: @escaping (Bool, Error?) -> Void) {
        smartClient.authorize { (patient, error) in
            completion(error == nil, error)
        }
    }

    public func updateComplete(objects: [HDSExternalObjectProtocol], success: Bool, error: Error?) {
        print("Update completed \(error != nil ? error!.localizedDescription : "")")
    }

    public func shouldDelete(resource: Resource, deletedObject: HKDeletedObject?, completion: @escaping (Bool, Error?) -> Void) {
        smartClient.authorize { (patient, error) in
            completion(error == nil, error)
        }
    }

    public func deleteComplete(success: Bool, error: Error?) {
        print("Delete completed \(error != nil ? error!.localizedDescription : "")")
    }
}
