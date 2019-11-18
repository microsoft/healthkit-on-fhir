//
//  BloodPressureMessageTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync
import Quick
import Nimble

class BloodPressureMessageSpec: QuickSpec {
    override func spec() {
        let authtypes = [HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!, HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!]
        let type = HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!
        let expectedDate = Date.init(timeIntervalSince1970: 0)
        let diastolicSample = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!, quantity: HKQuantity(unit: HKUnit(from: "mmHg"), doubleValue: 80), start: expectedDate, end: expectedDate)
        let systolicSample = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!, quantity: HKQuantity(unit: HKUnit(from: "mmHg"), doubleValue: 120), start: expectedDate, end: expectedDate)
        let object = HKCorrelation.init(type: HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!, start: expectedDate, end: expectedDate, objects: [diastolicSample, systolicSample])
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 200), start: Date(), end: Date())
        describe("BloodPressureMessage") {
            itBehavesLike("external object protocol") { ["externalObjectType" : BloodPressureMessage.self,
                                                         "authorizationTypes" : authtypes,
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("event hubs message") { ["externalObjectType" : BloodPressureMessage.self,
                                                   "object" : object,
                                                   "json" : "{\"diastolicUnit\":\"mmHg\",\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"diastolic\":80,\"uuid\":\"00000000-0000-0000-0000-000000000000\",\"systolic\":120,\"systolicUnit\":\"mmHg\"}"]
            }
        }
    }
}

