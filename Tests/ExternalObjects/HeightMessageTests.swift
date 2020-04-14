//
//  HeightMessageTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync
import Quick
import Nimble

class HeightMessageSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .height)!
        let expectedDate = Date.init(timeIntervalSince1970: 0)
        let object = HKQuantitySample(type: type, quantity: HKQuantity(unit: HKUnit(from: "cm"), doubleValue: 180), start: expectedDate, end: expectedDate)
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 180), start: Date(), end: Date())
        describe("HeightMessage") {
            itBehavesLike("external object protocol") { ["externalObjectType" : HeightMessage.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("event hubs message") { ["externalObjectType" : HeightMessage.self,
                                                   "object" : object,
                                                   "json" : "{\"unit\":\"cm\",\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"height\":180,\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"]
            }
        }
    }
}
