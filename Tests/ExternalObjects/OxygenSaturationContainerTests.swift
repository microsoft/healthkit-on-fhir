//
//  OxygenSaturationContainerTests.swift
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

class OxygenSaturationContainerSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        let expectedDate = Date.init(timeIntervalSince1970: 0)
        let object = HKQuantitySample(type: type, quantity: HKQuantity(unit: HKUnit(from: "%"), doubleValue: 98), start: expectedDate, end: expectedDate)
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 98), start: Date(), end: Date())
        describe("OxygenSaturationContainer") {
            itBehavesLike("external object protocol") { ["externalObjectType" : OxygenSaturationContainer.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("resource container protocol") { ["externalObjectType" : OxygenSaturationContainer.self,
                                                            "resourceType" : Observation.self,
                                                            "object" : object,
                                                            "deletedObject" : HKDeletedObject.testObject()]
            }
        }
    }
}
