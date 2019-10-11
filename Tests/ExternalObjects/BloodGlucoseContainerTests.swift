//
//  BloodGlucoseContainerTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import FHIR
import HealthKit
import HealthDataSync
import Quick
import Nimble

class BloodGlucoseContainerSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!
        let expectedDate = Date.init(timeIntervalSince1970: 0)
        let object = HKQuantitySample(type: type, quantity: HKQuantity(unit: HKUnit(from: "mg/dL"), doubleValue: 80), start: expectedDate, end: expectedDate)
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 200), start: Date(), end: Date())
        describe("BloodGlucoseContainer") {
            itBehavesLike("external object protocol") { ["externalObjectType" : BloodGlucoseContainer.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("resource container protocol") { ["externalObjectType" : BloodGlucoseContainer.self,
                                                            "resourceType" : Observation.self,
                                                            "object" : object,
                                                            "deletedObject" : HKDeletedObject.testObject()]
            }
        }
    }
}
