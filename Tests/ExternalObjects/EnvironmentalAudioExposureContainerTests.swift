//
//  EnvironmentalAudioExposureContainerTests.swift
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

class EnvironmentalAudioExposureContainerSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure)!
        let expectedStartDate = Date.init(timeIntervalSince1970: 0)
        let expectedEndDate = Date.init(timeIntervalSince1970: 60)
        let object = HKQuantitySample(type: type, quantity: HKQuantity(unit: HKUnit(from: "dBASPL"), doubleValue: 10), start: expectedStartDate, end: expectedEndDate)
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 200), start: Date(), end: Date())
        describe("EnvironmentalAudioExposureContainer") {
            itBehavesLike("external object protocol") { ["externalObjectType" : EnvironmentalAudioExposureContainer.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("resource container protocol") { ["externalObjectType" : EnvironmentalAudioExposureContainer.self,
                                                            "resourceType" : Observation.self,
                                                            "object" : object,
                                                            "deletedObject" : HKDeletedObject.testObject()]
            }
        }
    }
}
