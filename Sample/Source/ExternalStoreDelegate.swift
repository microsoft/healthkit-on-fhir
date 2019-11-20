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
    private let idMapSyncObject = NSObject()
    private var resourceIdMap = [String : String]()
    private let deviceCreationSyncObject = NSObject()
    private var deviceCreationCompletions = [String : [(String?, String?, Error?) -> Void]]()
    
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
        objc_sync_enter(self.idMapSyncObject)
        let patientId = resourceIdMap[IomtFhirDelegate.patientIdKey]
        objc_sync_exit(self.idMapSyncObject)
        
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
            
            objc_sync_enter(self.idMapSyncObject)
            self.resourceIdMap[IomtFhirDelegate.patientIdKey] = patientId
            objc_sync_exit(self.idMapSyncObject)
            
            completion(patientId, nil)
        }
    }
    
    private func getDeviceIdentifiers(object: HKObject?, patientId: String, completion: @escaping (String?, String?, Error?) -> Void ) {
        // Ensure the HKObject is not nil.
        guard let object = object else {
            completion(nil, nil, ExternalStoreDelegateError.hkObjectNil)
            return
        }
        
        let deviceIdentifier = uniqueIdentifier(patientId: patientId, sourceRevisionId: object.sourceRevision.source.bundleIdentifier)
        
        // Check if the device id has already been retrieved and stored in the resourceIdMap.
        objc_sync_enter(self.idMapSyncObject)
        let deviceId = resourceIdMap[deviceIdentifier]
        objc_sync_exit(self.idMapSyncObject)
        
        if deviceId != nil {
            completion(deviceIdentifier, deviceId, nil)
            return
        }
        
        objc_sync_enter(self.deviceCreationSyncObject)
        var creationCompletions = self.deviceCreationCompletions.removeValue(forKey: deviceIdentifier)
        if creationCompletions != nil {
            // No Device exists, however another thread is creating the device.
            creationCompletions?.append(completion)
            self.deviceCreationCompletions[deviceIdentifier] = creationCompletions
            print("Device creation in process, adding completion - Completion Count \(self.deviceCreationCompletions[deviceIdentifier]!.count)")
            objc_sync_exit(self.deviceCreationSyncObject)
            return
        }
        self.deviceCreationCompletions[deviceIdentifier] = [completion]
        objc_sync_exit(self.deviceCreationSyncObject)
        
        // Search the FHIR server for any device resources that have already been created.
        Device.search(["identifier" : DeviceFactory.healthKitIdentifierSystemKey + "|" + deviceIdentifier]).perform(smartClient.server) { (bundle, error) in
            // Ensure there is no error
            guard error == nil,
                bundle != nil else {
                self.completeDeviceCreation(deviceIdentifier: deviceIdentifier, deviceId: nil, error: error)
                return
            }
            
            // Add any devices related to the patient to the map.
            self.addToMap(devices: bundle!.resources())
            
            // Check if the device resource exists in the FHIR server.
            objc_sync_enter(self.idMapSyncObject)
            let deviceId = self.resourceIdMap[deviceIdentifier]
            objc_sync_exit(self.idMapSyncObject)
            
            if deviceId != nil {
                self.completeDeviceCreation(deviceIdentifier: deviceIdentifier, deviceId: deviceId, error: error)
                return
            }
            
            // No Device exists for the given HKObject - Create a new device in FHIR.
            self.createDevice(deviceIdentifier: deviceIdentifier, object: object, patientId: patientId)
        }
    }
    
    private func createDevice(deviceIdentifier: String, object: HKObject, patientId: String) {
        do {
            // Extract the HealthKit SourceRevision and Device data into a Device Resource.
            let device = try deviceFactory.device(from: object)
            
            // Add the patient id to the Device.
            addReference(patientId: patientId, sourceRevisionId: object.sourceRevision.source.bundleIdentifier, devices: [device])
            
            // Post the Device to the FHIR server.
            device.create(smartClient.server) { (error) in
                // Ensure there is no error
                guard error == nil else {
                    self.completeDeviceCreation(deviceIdentifier: deviceIdentifier, deviceId: nil, error: error)
                    return
                }
                
                // Add the newly created Device to the device map
                if let deviceIdentifier = device.identifier(for: DeviceFactory.healthKitIdentifierSystemKey),
                    let deviceId = device.id?.description {
                    objc_sync_enter(self.idMapSyncObject)
                    self.resourceIdMap[deviceIdentifier] = deviceId
                    objc_sync_exit(self.idMapSyncObject)
                    
                    self.completeDeviceCreation(deviceIdentifier: deviceIdentifier, deviceId: deviceId, error: nil)
                } else {
                    self.completeDeviceCreation(deviceIdentifier: deviceIdentifier, deviceId: nil, error: ExternalStoreDelegateError.deviceCreationFalied)
                }
            }
        } catch {
            self.completeDeviceCreation(deviceIdentifier: deviceIdentifier, deviceId: nil, error: error)
        }
    }
    
    private func completeDeviceCreation(deviceIdentifier: String, deviceId: String?, error: Error?) {
        objc_sync_enter(self.deviceCreationSyncObject)
        let creationCompletions = self.deviceCreationCompletions.removeValue(forKey: deviceIdentifier)
        if creationCompletions != nil {
            for creationCompletion in creationCompletions! {
                creationCompletion(deviceIdentifier, deviceId, error)
            }
        }
        objc_sync_exit(self.deviceCreationSyncObject)
    }
    
    private func addToMap(devices: [Device]) {
        for device in devices {
            if let deviceIdentifier = device.identifier(for: DeviceFactory.healthKitIdentifierSystemKey),
                let deviceId = device.id {
                objc_sync_enter(self.idMapSyncObject)
                resourceIdMap[deviceIdentifier] = deviceId.description
                objc_sync_exit(self.idMapSyncObject)
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
