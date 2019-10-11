//
//  DeviceExtensions.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import SMART

extension Device {
    public func identifier(for systemString: String) -> String? {
        if let identifiers = identifier {
            for identifier in identifiers {
                if identifier.system?.absoluteString == systemString {
                    return identifier.value?.description
                }
            }
        }
        return nil
    }
    
    public func setIdentifier(for systemString: String, valueString: String ) {
        let newIdentifier = Identifier()
        newIdentifier.system = FHIRURL(systemString)
        newIdentifier.value = FHIRString(valueString)
        
        if identifier == nil {
            identifier = [Identifier]()
        }
        
        if let identifiers = identifier {
            for identifier in identifiers {
                if identifier.system?.absoluteString == systemString {
                    identifier.value = newIdentifier.value
                    return
                }
            }
        }
        
        identifier?.append(newIdentifier)
    }
}
