//
//  FHIRSearchExtensionsTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import Quick
import Nimble
import IomtFhirClient
import HealthDataSync
import FHIR

class FHIRSearchExtensionsSpec: QuickSpec {
    override func spec() {
        describe("FHIRServerExtensions") {
            let mockServer = MockFHIRServer(baseURL: URL(string: "http://test")!, auth: nil)
            let search = Observation.search(["identifier" : "test"])
            beforeEach {
                mockServer.reset()
            }
                
            context("if performAndContinue is called") {
                context("the initial response yeilds an error") {
                    it("completes with an error and no bundle") {
                        mockServer.responses.append(MockFHIRServerResponse(error: FHIRError.error("Test Error")))
                        waitUntil { completed in
                            search.performAndContinue(mockServer, pageLimit: 10, callback: { (bundle, error) in
                                expect(error).toNot(beNil())
                                expect(bundle).to(beNil())
                                completed()
                            })
                        }
                    }
                }
                
                context("the initial response has no next link") {
                    context("there is a single entry") {
                        it("completes with a bundle with one entry") {
                            
                            let bundle = FHIR.Bundle()
                            bundle.entry = [BundleEntry()]
                            
                            mockServer.responses.append(MockFHIRServerResponse(resource: bundle))
                            waitUntil { completed in
                                search.performAndContinue(mockServer, pageLimit: 10, callback: { (bundle, error) in
                                    expect(error).to(beNil())
                                    expect(bundle).toNot(beNil())
                                    expect(bundle?.entry?.count) == 1
                                    completed()
                                })
                            }
                        }
                    }
                }
                
                context("the initial response has a next link") {
                    context("there is a single entry for each page") {
                        it("completes with a bundle with two entries") {
                            
                            let bundle1 = FHIR.Bundle()
                            bundle1.entry = [BundleEntry()]
                            bundle1.link = [BundleLink(relation: "next", url: FHIRURL("http://test")!)]
                            
                            let bundle2 = FHIR.Bundle()
                            bundle2.entry = [BundleEntry()]
                            
                            mockServer.responses.append(contentsOf: [MockFHIRServerResponse(resource: bundle1), MockFHIRServerResponse(resource: bundle2)])
                            waitUntil { completed in
                                search.performAndContinue(mockServer, pageLimit: 10, callback: { (bundle, error) in
                                    expect(error).to(beNil())
                                    expect(bundle).toNot(beNil())
                                    expect(bundle?.entry?.count) == 2
                                    completed()
                                })
                            }
                        }
                    }
                    
                    context("the next page has an error") {
                        it("completes with an error and no bundle") {
                            
                            let bundle1 = FHIR.Bundle()
                            bundle1.entry = [BundleEntry()]
                            bundle1.link = [BundleLink(relation: "next", url: FHIRURL("http://test")!)]
                            
                            mockServer.responses.append(contentsOf: [MockFHIRServerResponse(resource: bundle1), MockFHIRServerResponse(error: FHIRError.error("Test error"))])
                            waitUntil { completed in
                                search.performAndContinue(mockServer, pageLimit: 10, callback: { (bundle, error) in
                                    expect(error).toNot(beNil())
                                    expect(bundle).to(beNil())
                                    completed()
                                })
                            }
                        }
                    }
                    
                    context("the next page has a next link") {
                        context("there is a single entry for each page") {
                            it("completes with a bundle with three entries") {
                                
                                let bundle1 = FHIR.Bundle()
                                bundle1.entry = [BundleEntry()]
                                bundle1.link = [BundleLink(relation: "next", url: FHIRURL("http://test")!)]
                                
                                let bundle2 = FHIR.Bundle()
                                bundle2.entry = [BundleEntry()]
                                bundle2.link = [BundleLink(relation: "next", url: FHIRURL("http://test")!)]
                                
                                let bundle3 = FHIR.Bundle()
                                bundle3.entry = [BundleEntry()]
                                
                                mockServer.responses.append(contentsOf: [MockFHIRServerResponse(resource: bundle1), MockFHIRServerResponse(resource: bundle2), MockFHIRServerResponse(resource: bundle3)])
                                waitUntil { completed in
                                    search.performAndContinue(mockServer, pageLimit: 10, callback: { (bundle, error) in
                                        expect(error).to(beNil())
                                        expect(bundle).toNot(beNil())
                                        expect(bundle?.entry?.count) == 3
                                        completed()
                                    })
                                }
                            }
                        }
                        
                        context("the last page has an error") {
                            it("completes with an error and no bundle") {
                                
                                let bundle1 = FHIR.Bundle()
                                bundle1.entry = [BundleEntry()]
                                bundle1.link = [BundleLink(relation: "next", url: FHIRURL("http://test")!)]
                                
                                let bundle2 = FHIR.Bundle()
                                bundle2.entry = [BundleEntry()]
                                bundle2.link = [BundleLink(relation: "next", url: FHIRURL("http://test")!)]
                                
                                mockServer.responses.append(contentsOf: [MockFHIRServerResponse(resource: bundle1), MockFHIRServerResponse(resource: bundle2), MockFHIRServerResponse(error: FHIRError.error("Test error"))])
                                waitUntil { completed in
                                    search.performAndContinue(mockServer, pageLimit: 10, callback: { (bundle, error) in
                                        expect(error).toNot(beNil())
                                        expect(bundle).to(beNil())
                                        completed()
                                    })
                                }
                            }
                        }
                        
                        context("the page limit is reached") {
                            it("completes with a bundle with two entries and a page limit error") {
                                
                                let bundle1 = FHIR.Bundle()
                                bundle1.entry = [BundleEntry()]
                                bundle1.link = [BundleLink(relation: "next", url: FHIRURL("http://test")!)]
                                
                                let bundle2 = FHIR.Bundle()
                                bundle2.entry = [BundleEntry()]
                                bundle2.link = [BundleLink(relation: "next", url: FHIRURL("http://test")!)]
                                
                                let bundle3 = FHIR.Bundle()
                                bundle3.entry = [BundleEntry()]
                                
                                mockServer.responses.append(contentsOf: [MockFHIRServerResponse(resource: bundle1), MockFHIRServerResponse(resource: bundle2), MockFHIRServerResponse(resource: bundle3)])
                                waitUntil { completed in
                                    search.performAndContinue(mockServer, pageLimit: 2, callback: { (bundle, error) in
                                        expect(error).toNot(beNil())
                                        expect(error?.description) == "Page limit reached"
                                        expect(bundle).toNot(beNil())
                                        expect(bundle?.entry?.count) == 2
                                        completed()
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
