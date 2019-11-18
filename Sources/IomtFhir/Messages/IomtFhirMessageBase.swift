//
//  IomtFhirMessageBase.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit
import IomtFhirClient

open class IomtFhirMessageBase: Codable {
    /// The encoder used to serialize message data.
    public var jsonEncoder: JSONEncoder = {
       let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    /// The underlying HealthKit object used to create the message object
    internal var healthKitObject: HKObject?
    
    /// The underlying HKObject UUID
    public var uuid: UUID
    
    /// The start date for the underlying HKSample object.
    internal let startDate: Date
    
    /// The end date for the underlying HKSample object.
    internal let endDate: Date
    
    public init(uuid: UUID, startDate: Date, endDate: Date) {
        self.uuid = uuid
        self.startDate = startDate
        self.endDate = endDate
    }

    /// Generates an EventData object that facilites the transport of data to the Iomt Fhir Connector for Azure.
    ///
    /// - Returns:  A new EventData object.
    /// - Throws: Will throw if an error occurs attempting to serialize the the object to JSON.
    public func generateEventData() throws -> EventData {
        // Encode the object.
        return EventData(data: try jsonEncoder.encode(self))
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case startDate
        case endDate
    }
}
