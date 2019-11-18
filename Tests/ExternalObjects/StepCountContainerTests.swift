//
//  StepCountContainerTests.swift
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

class StepCountContainerSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let expectedStartDate = Date.init(timeIntervalSince1970: 0)
        let expectedEndDate = Date.init(timeIntervalSince1970: 60)
        let object = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 200), start: expectedStartDate, end: expectedEndDate)
        let incorrectObject = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!, quantity: HKQuantity(unit: HKUnit(from: "mg/dL"), doubleValue: 80), start: Date(), end: Date())
        describe("StepRateContainer") {
            itBehavesLike("external object protocol") { ["externalObjectType" : StepCountContainer.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("resource container protocol") { ["externalObjectType" : StepCountContainer.self,
                                                            "resourceType" : Observation.self,
                                                            "object" : object,
                                                            "deletedObject" : HKDeletedObject.testObject()]
            }
        }
    }
}
