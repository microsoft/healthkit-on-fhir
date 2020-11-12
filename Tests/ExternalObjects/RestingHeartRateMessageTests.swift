//
//  RestingHeartRateMessageTests.swift
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

class RestingHeartRateMessageSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        let expectedDate = Date.init(timeIntervalSince1970: 0)
        let object = HKQuantitySample(type: type, quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 14), start: expectedDate, end: expectedDate)
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 85), start: Date(), end: Date())
        describe("RestingHeartRateMessage") {
            itBehavesLike("external object protocol") { ["externalObjectType" : RestingHeartRateMessage.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("event hubs message") { ["externalObjectType" : RestingHeartRateMessage.self,
                                                   "object" : object,
                                                   "json" : "{\"restingHeartRate\":14,\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"unit\":\"beats\\/min\",\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"]
            }
        }
    }
}
