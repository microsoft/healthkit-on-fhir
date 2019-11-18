//
//  BundleExtensions.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import FHIR

extension FHIR.Bundle {
    private static let identifierKey = "identifier"
    
    public func resourceWithIdentifier(system: String, value: String) throws -> Resource? {
        let entry = try self.entry?.first(where:{
            if let resource = $0.resource {
                let json = try resource.asJSON()
                if let identifierCollection = json[Bundle.identifierKey] as? [FHIRJSON] {
                    for identifierJson in identifierCollection {
                        let identifier = try Identifier(json: identifierJson)
                        return identifier.contains(system: system, value: value)
                    }
                }
            }
            return false
        })
        
        return entry?.resource
    }
}
