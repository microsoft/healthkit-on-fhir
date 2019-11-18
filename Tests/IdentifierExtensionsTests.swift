//
//  IdentifierExtensionsTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import Quick
import Nimble
import FHIR

class IdentifierExtensionsSpec: QuickSpec {
    override func spec() {
        describe("IdentifierExtensions") {
            context("contains is called") {
                context("on an identifier with no system") {
                    let test = testObject(system: nil, value: "Test_Value")
                    it("returns false") {
                        expect(test.contains(system: "Test_System", value: "Test_Value")).to(beFalse())
                    }
                }
                context("on an identifier with no value") {
                    let test = testObject(system: "Test_System", value: nil)
                    it("returns false") {
                        expect(test.contains(system: "Test_System", value: "Test_Value")).to(beFalse())
                    }
                }
                context("on an identifier with a system and value") {
                    context("that contains the provided system and value parameters") {
                        let test = testObject(system: "Test_System", value: "Test_Value")
                        it("returns true") {
                            expect(test.contains(system: "Test_System", value: "Test_Value")).to(beTrue())
                        }
                    }
                    context("that does not contain the provided system") {
                        let test = testObject(system: "Test_Not_System", value: "Test_Value")
                        it("returns false") {
                            expect(test.contains(system: "Test_System", value: "Test_Value")).to(beFalse())
                        }
                    }
                    context("that does not contain the provided value") {
                        let test = testObject(system: "Test_System", value: "Test_Not_Value")
                        it("returns false") {
                            expect(test.contains(system: "Test_System", value: "Test_Value")).to(beFalse())
                        }
                    }
                    context("that does not contain the provided system or value") {
                        let test = testObject(system: "Test_Not_System", value: "Test_Not_Value")
                        it("returns false") {
                            expect(test.contains(system: "Test_System", value: "Test_Value")).to(beFalse())
                        }
                    }
                }
            }
        }
    }
    
    private func testObject(system: String?, value: String?) -> Identifier {
        let identifier = Identifier()
        identifier.system = system != nil ? FHIRURL(system!) : nil
        identifier.value = value != nil ? FHIRString(value!) : nil
        return identifier
    }
}
