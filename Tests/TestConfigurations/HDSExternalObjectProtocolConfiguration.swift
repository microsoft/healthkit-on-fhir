//
//  ExternalObjectProtocolConfiguration.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import HealthDataSync
import Quick
import Nimble

class ExternalObjectProtocolConfiguration : QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("external object protocol") { (sharedExampleContext: @escaping SharedExampleContext) in
            if let externalObjectType = sharedExampleContext()["externalObjectType"] as? HDSExternalObjectProtocol.Type {
                it("provides the expected authorization types") {
                    expect(externalObjectType.authorizationTypes()).to(contain(sharedExampleContext()["authorizationTypes"] as! [HKObjectType]))
                }
                it("provides the expected health kit object type") {
                    expect(externalObjectType.healthKitObjectType()) == sharedExampleContext()["healthKitObjectType"] as? HKObjectType
                }
                context("when externalObject is called") {
                    context("with the expected type") {
                        let object = sharedExampleContext()["object"] as! HKObject
                        let externalObject = externalObjectType.externalObject(object: object, converter: nil)
                        it("provides the expected uuid") {
                            expect(externalObject?.uuid) == object.uuid
                        }
                    }
                    context("with the incorrect type") {
                        it("returns nil") {
                            expect(externalObjectType.externalObject(object: sharedExampleContext()["incorrectObject"] as! HKObject, converter: nil)).to(beNil())
                        }
                    }
                }
            } else {
                fail("The test object does not conform to HDSExternalObjectProtocol")
            }
        }
    }
}
