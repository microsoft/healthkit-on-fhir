//
//  MockEventDataSender.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import IomtFhirClient

public class MockEventDataSender : EventDataSenderProtocol {
    
    public var completion: (Bool, Error?)?
    public var parameters: ([EventData], ((Bool, Error?) -> Void))?
    public var shouldThrow = false
    
    public func reset() {
        completion = nil
        parameters = nil
        shouldThrow = false
    }
    
    public func send(eventDatas: [EventData], completion: @escaping (Bool, Error?) -> Void) throws {
        if shouldThrow {
            throw MockError.sendError
        }
        parameters = (eventDatas, completion)
    }
    
    public func onSend(eventDatas: [EventData], completion: @escaping (Bool, Error?) -> Void) throws {
        if shouldThrow {
            throw MockError.sendError
        }
        parameters = (eventDatas, completion)
        
        if self.completion != nil {
            completion(self.completion!.0, self.completion?.1)
        }
    }
    
    public static func validateEvents(eventDatas: [EventData]) throws -> Int {
        return eventDatas.count
    }
}
