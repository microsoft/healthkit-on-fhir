//
//  WalkingHeartRateAverageMessageTests.swift
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

class WalkingHeartRateAverageMessageSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .walkingHeartRateAverage)!
        let expectedDate = Date.init(timeIntervalSince1970: 0)
        let object = HKQuantitySample(type: type, quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 29), start: expectedDate, end: expectedDate)
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 85), start: Date(), end: Date())
        describe("WalkingHeartRateAverageMessage") {
            itBehavesLike("external object protocol") { ["externalObjectType" : WalkingHeartRateAverageMessage.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("event hubs message") { ["externalObjectType" : WalkingHeartRateAverageMessage.self,
                                                   "object" : object,
                                                   "json" : "{\"unit\":\"beats\\/min\",\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"walkingHeartRateAverage\":29,\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"]
            }
        }
    }
}
