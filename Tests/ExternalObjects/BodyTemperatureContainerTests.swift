//
//  BodyTemperatureContainerTests.swift
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

class BodyTemperatureContainerSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!
        let expectedDate = Date.init(timeIntervalSince1970: 0)
        let object = HKQuantitySample(type: type, quantity: HKQuantity(unit: HKUnit(from: "degC"), doubleValue: 37), start: expectedDate, end: expectedDate)
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 37), start: Date(), end: Date())
        describe("BodyTemperatureContainer") {
            itBehavesLike("external object protocol") { ["externalObjectType" : BodyTemperatureContainer.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("resource container protocol") { ["externalObjectType" : BodyTemperatureContainer.self,
                                                            "resourceType" : Observation.self,
                                                            "object" : object,
                                                            "deletedObject" : HKDeletedObject.testObject()]
            }
        }
    }
}
