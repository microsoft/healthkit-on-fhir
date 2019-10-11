//
//  ConverterTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import Quick
import Nimble
import FHIR

class ConverterSpec: QuickSpec {
    override func spec() {
        describe("Converter") {
            context("convert object is called") {
                context("with a type not mapped") {
                    let test = testObjects()
                    let object = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .heartRate)!, quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 70), start: Date(), end: Date())
                    it("throws the expected error") {
                        expect { try test.converter.convert(object: object) as Device }.to(throwError(ConverterError.converterNotFound))
                    }
                }
                context("the resource factory throws") {
                    let test = testObjects()
                    let object = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .heartRate)!, quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 70), start: Date(), end: Date())
                    test.factory.resourceReturns.append(MockError.factoryError)
                    it("throws the expected error") {
                        expect { try test.converter.convert(object: object) as Observation }.to(throwError(MockError.factoryError))
                    }
                }
                context("the type is mapped and the factory does not throw") {
                    let test = testObjects()
                    let object = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .heartRate)!, quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 70), start: Date(), end: Date())
                    test.factory.resourceReturns.append(Observation())
                    it("throws the expected error") {
                        expect { try test.converter.convert(object: object) as Observation }.toNot(throwError())
                    }
                }
            }
            context("convert deleted object is called") {
                let test = testObjects()
                it("throws the expected error") {
                    expect { try test.converter.convert(deletedObject: HKDeletedObject.testObject()) }.to(throwError(ConverterError.notSupported))
                }
            }
        }
    }
    
    private func testObjects() -> (factory: MockResourceFactory, converter: Converter) {
        let factory = MockResourceFactory()
        let converter = Converter(converterMap: [Observation.resourceType : factory])
        return (factory, converter)
    }
}
