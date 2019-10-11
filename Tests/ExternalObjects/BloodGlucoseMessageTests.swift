//
//  BloodGlucoseMessageTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync
import Quick
import Nimble

class BloodGlucoseMessageSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!
        let expectedDate = Date.init(timeIntervalSince1970: 0)
        let object = HKQuantitySample(type: type, quantity: HKQuantity(unit: HKUnit(from: "mg/dL"), doubleValue: 80), start: expectedDate, end: expectedDate)
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 200), start: Date(), end: Date())
        describe("BloodGlucoseMessage") {
            itBehavesLike("external object protocol") { ["externalObjectType" : BloodGlucoseMessage.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("event hubs message") { ["externalObjectType" : BloodGlucoseMessage.self,
                                                   "object" : object,
                                                   "json" : "{\"unit\":\"mg\\/dL\",\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"bloodGlucose\":80,\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"]
            }
        }
    }
}
