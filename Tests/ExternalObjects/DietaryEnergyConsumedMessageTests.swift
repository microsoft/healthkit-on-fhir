//
//  DietaryEnergyConsumedMessageTests.swift
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

class DietaryEnergyConsumedMessageSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        let expectedDate = Date.init(timeIntervalSince1970: 0)
        let object = HKQuantitySample(type: type, quantity: HKQuantity(unit: HKUnit(from: "kcal"), doubleValue: 25), start: expectedDate, end: expectedDate)
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 85), start: Date(), end: Date())
        describe("DietaryEnergyConsumedMessage") {
            itBehavesLike("external object protocol") { ["externalObjectType" : DietaryEnergyConsumedMessage.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("event hubs message") { ["externalObjectType" : DietaryEnergyConsumedMessage.self,
                                                   "object" : object,
                                                   "json" : "{\"dietaryEnergyConsumed\":25,\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"unit\":\"kcal\",\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"]
            }
        }
    }
}
