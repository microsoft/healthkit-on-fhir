//
//  IdentifierExtensions.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import FHIR

extension Identifier {
    public func contains(system: String, value:String) -> Bool {
        if let identifierSystem = self.system?.absoluteString,
            let identifierValue = self.value?.description {
            return identifierSystem == system && identifierValue == value
        }
        
        return false
    }
}
