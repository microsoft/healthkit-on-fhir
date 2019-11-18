//
//  MockFHIRServerResponse.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import FHIR

public class MockFHIRServerResponse : FHIRServerResponse {
    public var status = 0
    
    public var headers = ["":""]
    
    public var body: Data?
    
    public var outcome: OperationOutcome?
    
    public var error: FHIRError?
    
    public let resource: Resource?
    
    init(resource: Resource) {
        self.resource = resource
    }
    
    init(error: FHIRError) {
        self.error = error
        self.resource = nil
    }
    
    public func responseResource<T>(ofType: T.Type) throws -> T where T : Resource {
        return resource as! T
    }
    
    public func applyBody(to: Resource) throws {
        
    }
    
    
}
