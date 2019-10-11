//
//  MockFHIRServer.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import FHIR

class MockFHIRServer : FHIRServer {
    
    public var performRequestCallCount = 0
    public var performRequestParams = [(String, FHIRRequestHandler)]()
    public var responses: [MockFHIRServerResponse] = []
    
    var baseURL: URL
    
    required init(baseURL base: URL, auth: [String : Any]?) {
        baseURL = base
    }
    
    public func reset() {
        performRequestCallCount = 0
        responses.removeAll()
        performRequestParams.removeAll()
    }
    
    func handlerForRequest(withMethod method: FHIRRequestMethod, resource: Resource?) -> FHIRRequestHandler? {
        return FHIRBaseRequestHandler(method, resource: resource)
    }
    
    func performRequest(against path: String, handler: FHIRRequestHandler, callback: @escaping ((FHIRServerResponse) -> Void)) {
        performRequestCallCount = performRequestCallCount + 1
        performRequestParams.append((path, handler))
        callback(responses.removeFirst())
    }
}
