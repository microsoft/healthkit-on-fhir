//
//  StepCountMessageTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync
import Quick
import Nimble

class StepCountMessageSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let expectedStartDate = Date.init(timeIntervalSince1970: 0)
        let expectedEndDate = Date.init(timeIntervalSince1970: 60)
        let object = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 200), start: expectedStartDate, end: expectedEndDate)
        let incorrectObject = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!, quantity: HKQuantity(unit: HKUnit(from: "mg/dL"), doubleValue: 80), start: Date(), end: Date())
        describe("StepCountMessage") {
            itBehavesLike("external object protocol") { ["externalObjectType" : StepCountMessage.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("event hubs message") { ["externalObjectType" : StepCountMessage.self,
                                                   "object" : object,
                                                   "json" : "{\"stepCount\":200,\"endDate\":\"1970-01-01T00:01:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"unit\":\"count\",\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"]
            }
        }
    }
}
