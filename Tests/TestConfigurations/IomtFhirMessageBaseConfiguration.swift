//
//  IomtFhirMessageBaseConfiguration.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync
import Quick
import Nimble

class IomtFhirMessageBaseConfiguration : QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("event hubs message") { (sharedExampleContext: @escaping SharedExampleContext) in
            if let messageType = sharedExampleContext()["externalObjectType"] as? HDSExternalObjectProtocol.Type {
                let message = messageType.externalObject(object: sharedExampleContext()["object"] as! HKObject, converter: nil) as! IomtFhirMessageBase
                context("when generateEventData is called") {
                    it("generates the expected event data object") {
                        message.uuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
                        let json = String(data: (try! message.generateEventData()).data, encoding: .utf8)
                        expect(json) == sharedExampleContext()["json"] as? String
                    }
                }
            } else {
                fail("the test object is not an IomtFhirMessageBase type")
            }
        }
    }
}
