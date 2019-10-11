//
//  BundleExtensions.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import SMART

extension SMART.Bundle {
    public func resources<T: Resource>() -> [T] {
        var resources = [T]()
        
        if self.entry != nil {
            for entry in self.entry! {
                if let resource = entry.resource as? T {
                    resources.append(resource)
                }
            }
        }
        
        return resources
    }
}
