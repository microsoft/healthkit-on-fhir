//
//  HKDeletedObjectExtensions.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit

extension HKDeletedObject {
    static func testObject() -> HKDeletedObject {
        let path = Bundle(for: IomtFhirMessageBaseConfiguration.self).path(forResource: "HKDeletedObject", ofType: nil)!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        return try! NSKeyedUnarchiver.unarchivedObject(ofClass: HKDeletedObject.self, from: data)!
    }
}
