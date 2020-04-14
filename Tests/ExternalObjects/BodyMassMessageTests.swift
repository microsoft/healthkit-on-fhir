//
//  BodyMassMessageTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync
import Quick
import Nimble

class BodyMassMessageSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let expectedDate = Date.init(timeIntervalSince1970: 0)
        let object = HKQuantitySample(type: type, quantity: HKQuantity(unit: HKUnit(from: "kg"), doubleValue: 85), start: expectedDate, end: expectedDate)
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 85), start: Date(), end: Date())
        describe("BodyMassMessage") {
            itBehavesLike("external object protocol") { ["externalObjectType" : BodyMassMessage.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("event hubs message") { ["externalObjectType" : BodyMassMessage.self,
                                                   "object" : object,
                                                   "json" : "{\"bodyMass\":85,\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"unit\":\"kg\",\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"]
            }
        }
    }
}
