//
//  FhirExternalStoreDelegateTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthDataSync
import HealthKit
import Quick
import Nimble
import FHIR

class FhirExternalStoreDelegateSpec: QuickSpec {
    override func spec() {
        describe("FhirExternalStoreDelegate") {
            context("fetchObjects is called on the external store") {
                context("with an empty array") {
                    let test = testObjects()
                    test.store.fetchObjects(with: [], completion: { (objects, error) in
                        it("it does not call shouldFetch on the delegate") {
                            expect(test.delegate.shouldFetchParams.count) == 0
                        }
                        it("it does not call fetchComplete on the delegate"){
                            expect(test.delegate.fetchCompleteParams.count) == 0
                        }
                    })
                }
                context("with multiple objects") {
                    context("the server responds with no error") {
                        let test = testObjects()
                        let objects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: MockObservationFactory())
                        test.delegate.shouldFetchCompletions.append((true, nil))
                        test.server.responses.append(FhirExternalStoreTestHelpers.generateServerResponse(with: objects))
                        test.store.fetchObjects(with: objects, completion: { (_, _) in
                            it("calls shouldFetch once") {
                                expect(test.delegate.shouldFetchParams.count) == 1
                            }
                            it("passes the expected objects to shouldFetch") {
                                for i in 0..<objects.count {
                                    expect(test.delegate.shouldFetchParams[0][i]).to(be(objects[i]))
                                }
                            }
                            it("calls fetchComplete once") {
                                expect(test.delegate.fetchCompleteParams.count) == 1
                            }
                            it("passes the expected objects to fetchComplete") {
                                for i in 0..<objects.count {
                                    expect(test.delegate.fetchCompleteParams[0].objects![i]).to(be(objects[i]))
                                }
                            }
                            it("passes the expected success boolean to fetchComplete") {
                                expect(test.delegate.fetchCompleteParams[0].success).to(beTrue())
                            }
                            it("passes the expected nil error to fetchComplete") {
                                expect(test.delegate.fetchCompleteParams[0].error).to(beNil())
                            }
                        })
                    }
                    context("the server responds with an error") {
                        let test = testObjects()
                        let objects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: MockObservationFactory())
                        test.delegate.shouldFetchCompletions.append((true, nil))
                        test.server.responses.append(MockFHIRServerResponse(error: FHIRError.error("Test error")))
                        test.store.fetchObjects(with: objects, completion: { (_, _) in
                            it("calls shouldFetch once") {
                                expect(test.delegate.shouldFetchParams.count) == 1
                            }
                            it("passes the expected objects to shouldFetch") {
                                for i in 0..<objects.count {
                                    expect(test.delegate.shouldFetchParams[0][i]).to(be(objects[i]))
                                }
                            }
                            it("calls fetchComplete once") {
                                expect(test.delegate.fetchCompleteParams.count) == 1
                            }
                            it("passes nil objects to fetchComplete") {
                                expect(test.delegate.fetchCompleteParams[0].objects).to(beNil())
                            }
                            it("passes the expected success boolean to fetchComplete") {
                                expect(test.delegate.fetchCompleteParams[0].success).to(beFalse())
                            }
                            it("passes the expected error to fetchComplete") {
                                expect(test.delegate.fetchCompleteParams[0].error).to(matchError(FHIRError.error("Test error")))
                            }
                        })
                    }
                    context("shouldFetch returns false and an error") {
                        let test = testObjects()
                        let objects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: MockObservationFactory())
                        test.delegate.shouldFetchCompletions.append((false, MockError.delegateError))
                        test.store.fetchObjects(with: objects, completion: { (_, _) in
                            it("does not make a request to the server") {
                                expect(test.server.performRequestParams.count) == 0
                            }
                            it("calls fetchComplete once") {
                                expect(test.delegate.fetchCompleteParams.count) == 1
                            }
                            it("passes nil objects to fetchComplete") {
                                expect(test.delegate.fetchCompleteParams[0].objects).to(beNil())
                            }
                            it("passes the expected success boolean to fetchComplete") {
                                expect(test.delegate.fetchCompleteParams[0].success).to(beFalse())
                            }
                            it("passes the expected error to fetchComplete") {
                                expect(test.delegate.fetchCompleteParams[0].error).to(matchError(MockError.delegateError))
                            }
                        })
                    }
                }
            }
            context("add is called on the external store") {
                context("with an empty array") {
                    let test = testObjects()
                    test.store.add(objects: [], completion: { (error) in
                        it("it does not call shouldAdd on the delegate") {
                            expect(test.delegate.shouldAddParams.count) == 0
                        }
                        it("it does not call addComplete on the delegate"){
                            expect(test.delegate.addCompleteParams.count) == 0
                        }
                    })
                }
                context("with multiple objects") {
                    context("the server responds with no error") {
                        let test = testObjects()
                        let objects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: MockObservationFactory())
                        let completions: [(Bool, Error?)] = [(true, nil), (true, nil), (true, nil), (true, nil), (true, nil)]
                        test.delegate.shouldAddCompletions.append(contentsOf: completions)
                        var responses = [MockFHIRServerResponse]()
                        for object in objects {
                            let response = FhirExternalStoreTestHelpers.generateServerResponse(with: [object])
                            responses.append(response)
                            test.server.responses.append(response)
                        }
                        test.store.add(objects: objects, completion: { (_) in
                            it("calls shouldAdd once per object") {
                                expect(test.delegate.shouldAddParams.count) == 5
                            }
                            it("passes the expected resource to shouldAdd") {
                                for i in 0..<objects.count {
                                    expect(test.delegate.shouldAddParams[i].resource).to(be(try! objects[i].getResource()))
                                }
                            }
                            it("calls addComplete once") {
                                expect(test.delegate.addCompleteParams.count) == 1
                            }
                            it("passes the expected objects to addComplete") {
                                for i in 0..<objects.count {
                                    expect(test.delegate.addCompleteParams[0].objects![i]).to(be(objects[i]))
                                }
                            }
                            it("passes the expected success boolean to addComplete") {
                                expect(test.delegate.addCompleteParams[0].success).to(beTrue())
                            }
                            it("passes the expected nil error to addComplete") {
                                expect(test.delegate.addCompleteParams[0].error).to(beNil())
                            }
                        })
                    }
                    context("the server responds with an error") {
                        let test = testObjects()
                        let objects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: MockObservationFactory())
                        let completions: [(Bool, Error?)] = [(true, nil), (true, nil), (true, nil), (true, nil), (true, nil)]
                        test.delegate.shouldAddCompletions.append(contentsOf: completions)
                        test.server.responses.append(MockFHIRServerResponse(error: FHIRError.error("Test error")))
                        test.store.add(objects: objects, completion: { (_) in
                            it("calls shouldAdd once per object") {
                                expect(test.delegate.shouldAddParams.count) == 1
                            }
                            it("passes the expected resource to shouldAdd") {
                                expect(test.delegate.shouldAddParams[0].resource).to(be(try! objects[0].getResource()))
                            }
                            it("calls addComplete once") {
                                expect(test.delegate.addCompleteParams.count) == 1
                            }
                            it("passes the expected objects to addComplete") {
                                for i in 0..<objects.count {
                                    expect(test.delegate.addCompleteParams[0].objects![i]).to(be(objects[i]))
                                }
                            }
                            it("passes the expected success boolean to addComplete") {
                                expect(test.delegate.addCompleteParams[0].success).to(beFalse())
                            }
                            it("passes the expected nil error to addComplete") {
                                expect(test.delegate.addCompleteParams[0].error).to(matchError(FHIRError.error("Test error")))
                            }
                        })
                    }
                    context("shouldAdd returns false and an error") {
                        let test = testObjects()
                        let objects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: MockObservationFactory())
                        test.delegate.shouldAddCompletions.append((false, MockError.delegateError))
                        test.store.add(objects: objects, completion: { (_) in
                            it("does not make a request to the server") {
                                expect(test.server.performRequestParams.count) == 0
                            }
                            it("calls addComplete once") {
                                expect(test.delegate.addCompleteParams.count) == 1
                            }
                            it("passes the expected objects to addComplete") {
                                for i in 0..<objects.count {
                                    expect(test.delegate.addCompleteParams[0].objects![i]).to(be(objects[i]))
                                }
                            }
                            it("passes the expected success boolean to addComplete") {
                                expect(test.delegate.addCompleteParams[0].success).to(beFalse())
                            }
                            it("passes the expected error to addComplete") {
                                expect(test.delegate.addCompleteParams[0].error).to(matchError(MockError.delegateError))
                            }
                        })
                    }
                }
            }
            context("update is called on the external store") {
                context("with an empty array") {
                    let test = testObjects()
                    test.store.update(objects: [], completion: { (error) in
                        it("it does not call shouldUpdate on the delegate") {
                            expect(test.delegate.shouldUpdateParams.count) == 0
                        }
                        it("it does not call updateComplete on the delegate"){
                            expect(test.delegate.updateCompleteParams.count) == 0
                        }
                    })
                }
                context("with multiple objects") {
                    context("the server responds with no error") {
                        let test = testObjects()
                        let objects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: MockObservationFactory(), addId: true)
                        let completions: [(Bool, Error?)] = [(true, nil), (true, nil), (true, nil), (true, nil), (true, nil)]
                        test.delegate.shouldUpdateCompletions.append(contentsOf: completions)
                        var responses = [MockFHIRServerResponse]()
                        for object in objects {
                            let response = FhirExternalStoreTestHelpers.generateServerResponse(with: [object])
                            responses.append(response)
                            test.server.responses.append(response)
                        }
                        test.store.update(objects: objects, completion: { (_) in
                            it("calls shouldUpdate once per object") {
                                expect(test.delegate.shouldUpdateParams.count) == 5
                            }
                            it("passes the expected resource to shouldUpdate") {
                                for i in 0..<objects.count {
                                    expect(test.delegate.shouldUpdateParams[i].resource).to(be(try! objects[i].getResource()))
                                }
                            }
                            it("calls updateComplete once") {
                                expect(test.delegate.updateCompleteParams.count) == 1
                            }
                            it("passes the expected objects to updateComplete") {
                                for i in 0..<objects.count {
                                    expect(test.delegate.updateCompleteParams[0].objects![i]).to(be(objects[i]))
                                }
                            }
                            it("passes the expected success boolean to updateComplete") {
                                expect(test.delegate.updateCompleteParams[0].success).to(beTrue())
                            }
                            it("passes the expected nil error to updateComplete") {
                                expect(test.delegate.updateCompleteParams[0].error).to(beNil())
                            }
                        })
                    }
                    context("the server responds with an error") {
                        let test = testObjects()
                        let objects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: MockObservationFactory(), addId: true)
                        let completions: [(Bool, Error?)] = [(true, nil), (true, nil), (true, nil), (true, nil), (true, nil)]
                        test.delegate.shouldUpdateCompletions.append(contentsOf: completions)
                        test.server.responses.append(MockFHIRServerResponse(error: FHIRError.error("Test error")))
                        test.store.update(objects: objects, completion: { (_) in
                            it("calls shouldUpdate once per object") {
                                expect(test.delegate.shouldUpdateParams.count) == 1
                            }
                            it("passes the expected resource to shouldUpdate") {
                                expect(test.delegate.shouldUpdateParams[0].resource).to(be(try! objects[0].getResource()))
                            }
                            it("calls updateComplete once") {
                                expect(test.delegate.updateCompleteParams.count) == 1
                            }
                            it("passes the expected objects to updateComplete") {
                                for i in 0..<objects.count {
                                    expect(test.delegate.updateCompleteParams[0].objects![i]).to(be(objects[i]))
                                }
                            }
                            it("passes the expected success boolean to updateComplete") {
                                expect(test.delegate.updateCompleteParams[0].success).to(beFalse())
                            }
                            it("passes the expected nil error to updateComplete") {
                                expect(test.delegate.updateCompleteParams[0].error).to(matchError(FHIRError.error("Test error")))
                            }
                        })
                    }
                    context("shouldUpdate returns false and an error") {
                        let test = testObjects()
                        let objects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: MockObservationFactory(), addId: true)
                        test.delegate.shouldUpdateCompletions.append((false, MockError.delegateError))
                        test.store.update(objects: objects, completion: { (_) in
                            it("does not make a request to the server") {
                                expect(test.server.performRequestParams.count) == 0
                            }
                            it("calls updateComplete once") {
                                expect(test.delegate.updateCompleteParams.count) == 1
                            }
                            it("passes the expected objects to updateComplete") {
                                for i in 0..<objects.count {
                                    expect(test.delegate.updateCompleteParams[0].objects![i]).to(be(objects[i]))
                                }
                            }
                            it("passes the expected success boolean to updateComplete") {
                                expect(test.delegate.updateCompleteParams[0].success).to(beFalse())
                            }
                            it("passes the expected error to updateComplete") {
                                expect(test.delegate.updateCompleteParams[0].error).to(matchError(MockError.delegateError))
                            }
                        })
                    }
                }
            }
            context("delete is called on the external store") {
                context("with an empty array") {
                    let test = testObjects()
                    test.store.delete(deletedObjects: [], completion: { (error) in
                        it("it does not call shouldDelete on the delegate") {
                            expect(test.delegate.shouldDeleteParams.count) == 0
                        }
                        it("it does not call deleteComplete on the delegate"){
                            expect(test.delegate.deleteCompleteParams.count) == 0
                        }
                    })
                }
                context("with multiple objects") {
                    context("the server responds with no error") {
                        let test = testObjects()
                        let deletedObjects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: MockObservationFactory(), addId: true)
                        let completions: [(Bool, Error?)] = [(true, nil), (true, nil), (true, nil), (true, nil), (true, nil)]
                        test.delegate.shouldDeleteCompletions.append(contentsOf: completions)
                        var responses = [MockFHIRServerResponse]()
                        for object in deletedObjects {
                            let response = FhirExternalStoreTestHelpers.generateServerResponse(with: [object])
                            responses.append(response)
                            test.server.responses.append(response)
                        }
                        test.store.delete(deletedObjects: deletedObjects, completion: { (_) in
                            it("calls shouldDelete once per object") {
                                expect(test.delegate.shouldDeleteParams.count) == 5
                            }
                            it("passes the expected resource to shouldDelete") {
                                for i in 0..<deletedObjects.count {
                                    expect(test.delegate.shouldDeleteParams[i].resource).to(be(try! deletedObjects[i].getResource()))
                                }
                            }
                            it("calls deleteComplete once") {
                                expect(test.delegate.deleteCompleteParams.count) == 1
                            }
                            it("passes the expected success boolean to deleteComplete") {
                                expect(test.delegate.deleteCompleteParams[0].success).to(beTrue())
                            }
                            it("passes the expected nil error to deleteComplete") {
                                expect(test.delegate.deleteCompleteParams[0].error).to(beNil())
                            }
                        })
                    }
                    context("the server responds with an error") {
                        let test = testObjects()
                        let objects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: MockObservationFactory(), addId: true)
                        let completions: [(Bool, Error?)] = [(true, nil), (true, nil), (true, nil), (true, nil), (true, nil)]
                        test.delegate.shouldDeleteCompletions.append(contentsOf: completions)
                        test.server.responses.append(MockFHIRServerResponse(error: FHIRError.error("Test error")))
                        test.store.delete(deletedObjects: objects, completion: { (_) in
                            it("calls shouldDelete once per object") {
                                expect(test.delegate.shouldDeleteParams.count) == 1
                            }
                            it("passes the expected resource to shouldDelete") {
                                expect(test.delegate.shouldDeleteParams[0].resource).to(be(try! objects[0].getResource()))
                            }
                            it("calls deleteComplete once") {
                                expect(test.delegate.deleteCompleteParams.count) == 1
                            }
                            it("passes the expected success boolean to deleteComplete") {
                                expect(test.delegate.deleteCompleteParams[0].success).to(beFalse())
                            }
                            it("passes the expected nil error to deleteComplete") {
                                expect(test.delegate.deleteCompleteParams[0].error).to(matchError(FHIRError.error("Test error")))
                            }
                        })
                    }
                    context("shouldDelete returns false and an error") {
                        let test = testObjects()
                        let objects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: MockObservationFactory(), addId: true)
                        test.delegate.shouldDeleteCompletions.append((false, MockError.delegateError))
                        test.store.delete(deletedObjects: objects, completion: { (_) in
                            it("does not make a request to the server") {
                                expect(test.server.performRequestParams.count) == 0
                            }
                            it("calls deleteComplete once") {
                                expect(test.delegate.deleteCompleteParams.count) == 1
                            }
                            it("passes the expected success boolean to deleteComplete") {
                                expect(test.delegate.deleteCompleteParams[0].success).to(beFalse())
                            }
                            it("passes the expected error to deleteComplete") {
                                expect(test.delegate.deleteCompleteParams[0].error).to(matchError(MockError.delegateError))
                            }
                        })
                    }
                }
            }
        }
    }
    
    private func testObjects() -> (delegate: MockFhirExternalStoreDelegate, server: MockFHIRServer, store: FhirExternalStore) {
        let delegate = MockFhirExternalStoreDelegate()
        let server = MockFHIRServer(baseURL: URL(string: "https://test/")!, auth: nil)
        let store = FhirExternalStore(server: server)
        store.delegate = delegate
        return (delegate, server, store)
    }
    
    private func objectContainers(count: Int) -> [HDSExternalObjectProtocol] {
        var containers = [HDSExternalObjectProtocol]()
        for _ in 0..<count {
            let object = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .heartRate)!, quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 66), start: Date(), end: Date())
            containers.append(HeartRateContainer.externalObject(object: object, converter: nil)!)
        }
        return containers
    }
}
