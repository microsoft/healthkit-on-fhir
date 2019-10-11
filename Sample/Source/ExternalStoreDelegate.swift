//
//  ExternalStoreDelegate.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthKitToFhir
import SMART

public class ExternalStoreDelegate {
    private static let patientIdKey = "PatientId"
    
    public let smartClient: Client
    private let deviceFactory: DeviceFactory
    private let syncObject = NSObject()
    private var resourceIdMap = [String : String]()
    
    public init(smartClient: Client, deviceFactory: DeviceFactory) {
        self.smartClient = smartClient
        self.deviceFactory = deviceFactory
    }
    
    public func getPatientAndDeviceIds(object: HKObject?, completion: @escaping (String?, String?, String?, Error?) -> Void ) {
        // Get the patient id from the FHIR server
        getPatientId { (patientId, error) in
            // Ensure there is no error and that the patient id is not nil.
            guard error == nil,
                let patientId = patientId else {
                    completion(nil, nil, nil, error)
                    return
            }
            
            self.getDeviceIdentifiers(object: object, patientId: patientId) { (deviceIdentifier, deviceId, error) in
                // Ensure there is no error
                guard error == nil else {
                    completion(nil, nil, nil, error)
                    return
                }
                
                completion(patientId, deviceIdentifier, deviceId, nil)
            }
        }
    }
    
    private func getPatientId(completion: @escaping (String?, Error?) -> Void ) {
        // Check if the patient id has already been retrieved and stored in the resourceIdMap.
        objc_sync_enter(self.syncObject)
        let patientId = resourceIdMap[IomtFhirDelegate.patientIdKey]
        objc_sync_exit(self.syncObject)
        
        if patientId != nil {
            completion(patientId, nil)
            return
        }
        
        smartClient.server.fetchAuthenticatedPatient { (patient, error) in
            // Ensure there is no error
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            // Ensure the patient resource exists.
            guard let patientId = patient?.id?.description else {
                completion(nil, ExternalStoreDelegateError.patientDoesNotExist)
                return
            }
            
            objc_sync_enter(self.syncObject)
            self.resourceIdMap[IomtFhirDelegate.patientIdKey] = patientId
            objc_sync_exit(self.syncObject)
            
            completion(patientId, nil)
        }
    }
    
    private func getDeviceIdentifiers(object: HKObject?, patientId: String, completion: @escaping (String?, String?, Error?) -> Void ) {
        // Ensure the HKObject is not nil.
        guard let object = object else {
            completion(nil, nil, ExternalStoreDelegateError.hkObjectNil)
            return
        }
        
        let identifier = uniqueIdentifier(patientId: patientId, sourceRevisionId: object.sourceRevision.source.bundleIdentifier)
        
        // Check if the device id has already been retrieved and stored in the resourceIdMap.
        objc_sync_enter(self.syncObject)
        let deviceId = resourceIdMap[identifier]
        objc_sync_exit(self.syncObject)
        
        if deviceId != nil {
            completion(identifier, deviceId, nil)
            return
        }
        
        // Search the FHIR server for any device resources that have already been created.
        Device.search(["identifier" : DeviceFactory.healthKitIdentifierSystemKey + "|" + identifier]).perform(smartClient.server) { (bundle, error) in
            // Ensure there is no error
            guard error == nil,
                bundle != nil else {
                completion(nil, nil, error)
                return
            }
            
            // Add any devices related to the patient to the map.
            self.addToMap(devices: bundle!.resources())
            
            // Check if the device resource exists in the FHIR server.
            objc_sync_enter(self.syncObject)
            let deviceId = self.resourceIdMap[identifier]
            objc_sync_exit(self.syncObject)
            
            if deviceId != nil {
                completion(identifier, deviceId, nil)
                return
            }
            
            // No Device exists for the given HKObject - Create a new device in FHIR.
            self.createDevice(object: object, patientId: patientId, completion: completion)
        }
    }
    
    private func createDevice(object: HKObject, patientId: String, completion: @escaping (String?, String?, Error?) -> Void ) {
        do {
            // Extract the HealthKit SourceRevision and Device data into a Device Resource.
            let device = try deviceFactory.device(from: object)
            
            // Add the patient id to the Device.
            addReference(patientId: patientId, sourceRevisionId: object.sourceRevision.source.bundleIdentifier, devices: [device])
            
            // Post the Device to the FHIR server.
            device.create(smartClient.server) { (error) in
                // Ensure there is no error
                guard error == nil else {
                    completion(nil, nil, error)
                    return
                }
                
                // Add the newly created Device to the device map
                if let deviceIdentifier = device.identifier(for: DeviceFactory.healthKitIdentifierSystemKey),
                    let deviceId = device.id?.description {
                    objc_sync_enter(self.syncObject)
                    self.resourceIdMap[deviceIdentifier] = deviceId
                    objc_sync_exit(self.syncObject)
                    
                    completion(deviceIdentifier, deviceId, nil)
                } else {
                    completion(nil, nil, ExternalStoreDelegateError.deviceCreationFalied)
                }
            }
            
        } catch {
            completion(nil, nil, error)
        }
    }
    
    private func addToMap(devices: [Device]) {
        for device in devices {
            if let deviceIdentifier = device.identifier(for: DeviceFactory.healthKitIdentifierSystemKey),
                let deviceId = device.id {
                objc_sync_enter(self.syncObject)
                resourceIdMap[deviceIdentifier] = deviceId.description
                objc_sync_exit(self.syncObject)
            }
        }
    }
    
    private func addReference(patientId: String, sourceRevisionId: String, devices: [Device]) {
        for device in devices {
            // Set the reference to the patient
            let reference = Reference()
            reference.reference = FHIRString("Patient/\(patientId)")
            device.patient = reference
            
            // Set a unique identifier for the device
            let identifier = uniqueIdentifier(patientId: patientId, sourceRevisionId: sourceRevisionId)
            device.setIdentifier(for: DeviceFactory.healthKitIdentifierSystemKey, valueString: identifier)
        }
    }
    
    private func uniqueIdentifier(patientId: String, sourceRevisionId: String) -> String {
        // Create a unique device identifier using the sourceRevision.source.bundleIdentifier with the patient id appended to it
        // sourceRevision.source.bundleIdentifier may not be unique - appending the patient id ensures uniqueness.
        return sourceRevisionId + "." + patientId
    }
}
