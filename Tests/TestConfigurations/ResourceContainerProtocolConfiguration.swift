//
//  ResourceContainerProtocolConfiguration.swift
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

class ResourceContainerProtocolConfiguration : QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("resource container protocol") { (sharedExampleContext: @escaping SharedExampleContext) in
            if let externalObjectType = sharedExampleContext()["externalObjectType"] as? HDSExternalObjectProtocol.Type {
                let object = sharedExampleContext()["object"] as! HKObject
                let deletedObject = sharedExampleContext()["deletedObject"] as! HKDeletedObject
                context("externalObject with object called") {
                    let container = externalObjectType.externalObject(object: object, converter: nil) as! ResourceContainerProtocol
                    it("provides the expected resource type") {
                        expect(container.resourceType).to(be(sharedExampleContext()["resourceType"] as! Resource.Type))
                    }
                    it("provides the expected healthKitObject") {
                        expect(container.healthKitObject) == object
                    }
                    it("provides the expected uuid") {
                        expect(container.uuid) == object.uuid
                    }
                }
                context("externalObject with deleted object called") {
                    let container = externalObjectType.externalObject(deletedObject: deletedObject, converter: nil) as! ResourceContainerProtocol
                    it("provides the expected resource type") {
                        expect(container.resourceType).to(be(sharedExampleContext()["resourceType"] as! Resource.Type))
                    }
                    it("provides the expected healthKitDeletedObject") {
                        expect(container.healthKitDeletedObject) == deletedObject
                    }
                    it("provides the expected uuid") {
                        expect(container.uuid) == deletedObject.uuid
                    }
                }
                context("getResource is called") {
                    context("on a container created with an HKObject") {
                        context("and a converter") {
                            let converter = MockConverter()
                            converter.convertObjectReturns.append(Observation())
                            let container = externalObjectType.externalObject(object: object, converter: converter) as! ResourceContainerProtocol
                            let _ = try! container.getResource()
                            it("calls convert on the converter with the expected object") {
                                expect(converter.convertObjectsParams[0]) == object
                            }
                            context("the converter throws an error") {
                                let converter = MockConverter()
                                converter.convertObjectReturns.append(MockError.converterError)
                                let container = externalObjectType.externalObject(object: object, converter: converter) as! ResourceContainerProtocol
                                it("throws the expected error") {
                                    expect{ try container.getResource() }.to(throwError(MockError.converterError))
                                }
                            }
                        }
                        context("without a converter") {
                            let container = externalObjectType.externalObject(object: object, converter: nil) as! ResourceContainerProtocol
                            it("throws the expected error") {
                                expect{ try container.getResource() }.to(throwError(ConverterError.requiredConverterNotProvided))
                            }
                        }
                    }
                    context("on a container created with an HKDeletedObject") {
                        let converter = MockConverter()
                        converter.convertDeletedObjectReturns.append(Observation())
                        let container = externalObjectType.externalObject(deletedObject: deletedObject, converter: converter) as! ResourceContainerProtocol
                        it("throws the expected error") {
                            expect{ try container.getResource() }.to(throwError(ConverterError.noObjectToConvert))
                        }
                    }
                }
            } else {
                fail("The test object does not conform to HDSExternalObjectProtocol")
            }
        }
    }
}
