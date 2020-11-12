//
//  EnvironmentalAudioExposureMessageTests.swift
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

class EnvironmentalAudioExposureMessageSpec: QuickSpec {
    override func spec() {
        let type = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure)!
        let expectedStartDate = Date.init(timeIntervalSince1970: 0)
        let expectedEndDate = Date.init(timeIntervalSince1970: 60)
        let object = HKQuantitySample(type: type, quantity: HKQuantity(unit: HKUnit(from: "dBASPL"), doubleValue: 10), start: expectedStartDate, end: expectedEndDate)
        let incorrectObject = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit(from: "count"), doubleValue: 85), start: Date(), end: Date())
        describe("EnvironmentalAudioExposureMessage") {
            itBehavesLike("external object protocol") { ["externalObjectType" : EnvironmentalAudioExposureMessage.self,
                                                         "authorizationTypes" : [type],
                                                         "healthKitObjectType" : type,
                                                         "object" : object,
                                                         "incorrectObject" : incorrectObject]
            }
            itBehavesLike("event hubs message") { ["externalObjectType" : EnvironmentalAudioExposureMessage.self,
                                                   "object" : object,
                                                   "json" : "{\"unit\":\"dB(SPL)\",\"endDate\":\"1970-01-01T00:01:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"environmentalAudioExposure\":10,\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"]
            }
        }
    }
}
