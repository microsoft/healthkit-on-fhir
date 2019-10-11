//
//  BloodPressureContainerTests.swift
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

class BloodPressureContainerSpec: QuickSpec {
    override func spec() {
        let authtypes = [HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!, HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!]
        let type = HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!
        let expectedDate = Date.init(timeIntervalSince1970: 0)
        let diastolicSample = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!, quantity: HKQuantity(unit: HKUnit(from: "mmHg"), doubleValue: 80), start: expectedDate, end: expectedDate)
        let systolicSample = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!, quantity: HKQuantity(unit: HKUnit(from: "mmHg"), doubleValue: 120), start: expectedDate, end: expectedDate)
        let object = HKCorrelation.init(type: HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!, start: expectedDate, end: expectedDate, objects: [diastolicSample, systolicSample])
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 200), start: Date(), end: Date())
        describe("BloodPressureContainer") {
            itBehavesLike("external object protocol") { ["externalObjectType" : BloodPressureContainer.self,
                                                         "authorizationTypes" : authtypes,
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("resource container protocol") { ["externalObjectType" : BloodPressureContainer.self,
                                                            "resourceType" : Observation.self,
                                                            "object" : object,
                                                            "deletedObject" : HKDeletedObject.testObject()]
            }
        }
    }
}
