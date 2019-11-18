//
//  BundleExtensionsTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import Quick
import Nimble
import FHIR

class BundleExtensionsSpec: QuickSpec {
    override func spec() {
        describe("BundleExtensions") {
            context("resourceWithIdentifier is called") {
                context("the bundle has one entry") {
                    context("the entry contains a resource matching the identifer") {
                        let expectedSystem = "Test_System"
                        let expectedValue = "Test_Value"
                        let bundle = FHIR.Bundle()
                        bundle.entry = entries(identifiers: [(expectedSystem, expectedValue)])
                        it("returns the expected resource") {
                            let resource = try? bundle.resourceWithIdentifier(system: expectedSystem, value: expectedValue) as? Observation
                            expect(resource?.identifier?[0].system?.absoluteString) == expectedSystem
                            expect(resource?.identifier?[0].value?.description) == expectedValue
                        }
                        
                    }
                    context("the entry does not have a resource matching the identifer") {
                        let bundle = FHIR.Bundle()
                        bundle.entry = entries(identifiers: [("Test_System", "Test_Value")])
                        it("returns nil") {
                            expect { try bundle.resourceWithIdentifier(system: "Not_Found_System", value: "Not_Found_Value") }.to(beNil())
                        }
                    }
                    context("the entry does not have a resource") {
                        let bundle = FHIR.Bundle()
                        bundle.entry = [BundleEntry()]
                        it("returns nil") {
                            expect { try bundle.resourceWithIdentifier(system: "Test_System", value: "Test_Value") }.to(beNil())
                        }
                    }
                    context("the entry has a resource is malformed") {
                        let bundle = FHIR.Bundle()
                        bundle.entry = entries(identifiers: [("Test_System", "Test_Value")])
                        (bundle.entry?[0].resource as! Observation).code = nil
                        it("returns nil") {
                            expect { try bundle.resourceWithIdentifier(system: "Test_System", value: "Test_Value") }.to(throwError())
                        }
                    }
                    context("the entry does not contain an identifier") {
                        let bundle = FHIR.Bundle()
                        bundle.entry = entries(identifiers: [("Test_System", "Test_Value")])
                        (bundle.entry?[0].resource as! Observation).identifier = nil
                        it("returns nil") {
                            expect { try bundle.resourceWithIdentifier(system: "Test_System", value: "Test_Value") }.to(beNil())
                        }
                    }
                }
                context("the bundle has multiple entries") {
                    context("an entry contains a resource matching the identifer") {
                        let expectedSystem = "Test_System"
                        let expectedValue = "Test_Value"
                        let bundle = FHIR.Bundle()
                        bundle.entry = entries(identifiers: [("Not_Found_System_1", "Not_Found_Value_1")])
                        bundle.entry?.append(contentsOf: entries(identifiers: [("Not_Found_System_2", "Not_Found_Value_2")]))
                        bundle.entry?.append(contentsOf: entries(identifiers: [(expectedSystem, expectedValue)]))
                        bundle.entry?.append(contentsOf: entries(identifiers: [("Not_Found_System_3", "Not_Found_Value_3")]))
                        bundle.entry?.append(contentsOf: entries(identifiers: [("Not_Found_System_4", "Not_Found_Value_4")]))
                        it("returns the expected resource") {
                            let resource = try? bundle.resourceWithIdentifier(system: expectedSystem, value: expectedValue) as? Observation
                            expect(resource?.identifier?[0].system?.absoluteString) == expectedSystem
                            expect(resource?.identifier?[0].value?.description) == expectedValue
                        }
                    }
                }
            }
        }
    }
    
    private func entries(identifiers: [(system: String, value: String)]? = nil) -> [BundleEntry] {
        var entries = [BundleEntry]()
        if let ids = identifiers {
            for id in ids {
                let identifier = Identifier()
                identifier.system = FHIRURL(id.system)
                identifier.value = FHIRString(id.value)
                
                let observation = Observation()
                observation.identifier = [identifier]
                observation.status = .final
                observation.code = CodeableConcept()
                
                let entry = BundleEntry()
                entry.resource = observation
                
                entries.append(entry)
            }
        }
        return entries
    }
}
