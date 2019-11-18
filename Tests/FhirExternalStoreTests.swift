//
//  FhirExternalStoreTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Quick
import Nimble
import IomtFhirClient
import HealthKitToFhir
import HealthDataSync
import FHIR
import HealthKit

class FHIRExternalStoreSpec: QuickSpec {
    
    private let mockObservationFactory = MockObservationFactory()
    
    override func spec() {
        describe("FHIRExternalStore") {
            
            let mockServer = MockFHIRServer(baseURL: URL(string: "http://test")!, auth: nil)
            let store = FhirExternalStore(server: mockServer)
            beforeEach {
                mockServer.reset()
                self.mockObservationFactory.reset()
            }
            
            context("if the fetchObjects method is called") {
                var fetchObjects = [MockObservationContainer]()
                
                context("the objects array is empty") {
                    it("calls the completion with no objects and no error") {
                        waitUntil { completed in
                            store.fetchObjects(with: fetchObjects, completion: { (objects, error) in
                                expect(objects).to(beNil())
                                expect(error).to(beNil())
                                completed()
                            })
                        }
                    }
                }
                
                context("the objects array contains a single object") {
                    
                    beforeEach {
                        fetchObjects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 1, mockObservationFactory: self.mockObservationFactory)
                    }
                    
                    context("not found in the external store") {
                        it("calls the completion with no objects and no error") {
                            
                            mockServer.responses.append(FhirExternalStoreTestHelpers.generateServerResponse(with: [MockObservationContainer]()))
                            
                            waitUntil { completed in
                                store.fetchObjects(with: fetchObjects, completion: { (objects, error) in
                                    expect(objects?.count) == 0
                                    expect(error).to(beNil())
                                    completed()
                                })
                            }
                        }
                    }
                    
                    context("found in the external store") {
                        it("calls the completion with one objects and no error") {
                            
                            mockServer.responses.append(FhirExternalStoreTestHelpers.generateServerResponse(with: fetchObjects))
                            
                            waitUntil { completed in
                                store.fetchObjects(with: fetchObjects, completion: { (objects, error) in
                                    expect(objects).toNot(beNil())
                                    expect(objects?.count) == 1
                                    expect(error).to(beNil())
                                    completed()
                                })
                            }
                        }
                    }
                    
                    context("the external store returns an error") {
                        it("calls the completion with no objects and an error") {
                            
                            mockServer.responses.append(MockFHIRServerResponse(error: FHIRError.error("Test error")))
                            
                            waitUntil { completed in
                                store.fetchObjects(with: fetchObjects, completion: { (objects, error) in
                                    expect(objects).to(beNil())
                                    expect(error).toNot(beNil())
                                    expect((error as? FHIRError)?.description) == "Test error"
                                    completed()
                                })
                            }
                        }
                    }
                }
                
                context("the objects array contains 20 objects") {
                    
                    beforeEach {
                        fetchObjects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 20, mockObservationFactory: self.mockObservationFactory)
                    }
                    
                    it("batches the requests to the external store in groups of 10") {
                        
                        mockServer.responses.append(contentsOf: [FhirExternalStoreTestHelpers.generateServerResponse(with: Array(fetchObjects[0...9])), FhirExternalStoreTestHelpers.generateServerResponse(with: Array(fetchObjects[10...19]))])
                        
                        waitUntil { completed in
                            store.fetchObjects(with: fetchObjects, completion: { (objects, error) in
                                expect(mockServer.performRequestCallCount) == 2
                                completed()
                            })
                        }
                    }
                    
                    context("not found in the external store") {
                        it("calls the completion with no objects and no error") {
                            
                            mockServer.responses.append(contentsOf: [FhirExternalStoreTestHelpers.generateServerResponse(with: [MockObservationContainer]()), FhirExternalStoreTestHelpers.generateServerResponse(with: [MockObservationContainer]())])
                            
                            waitUntil { completed in
                                store.fetchObjects(with: fetchObjects, completion: { (objects, error) in
                                    expect(objects?.count) == 0
                                    expect(error).to(beNil())
                                    completed()
                                })
                            }
                        }
                    }
                    
                    context("all found in the external store") {
                        it("calls the completion with 20 objects and no error") {
                            
                            mockServer.responses.append(contentsOf: [FhirExternalStoreTestHelpers.generateServerResponse(with: Array(fetchObjects[0...9])), FhirExternalStoreTestHelpers.generateServerResponse(with: Array(fetchObjects[10...19]))])
                            
                            waitUntil { completed in
                                store.fetchObjects(with: fetchObjects, completion: { (objects, error) in
                                    expect(objects).toNot(beNil())
                                    expect(objects?.count) == 20
                                    expect(error).to(beNil())
                                    completed()
                                })
                            }
                        }
                    }
                    
                    context("half found in the external store") {
                        it("calls the completion with 10 objects and no error") {
                            
                            mockServer.responses.append(contentsOf: [FhirExternalStoreTestHelpers.generateServerResponse(with: Array(fetchObjects[0...3])), FhirExternalStoreTestHelpers.generateServerResponse(with: Array(fetchObjects[12...17]))])
                            
                            waitUntil { completed in
                                store.fetchObjects(with: fetchObjects, completion: { (objects, error) in
                                    expect(objects).toNot(beNil())
                                    expect(objects?.count) == 10
                                    expect(error).to(beNil())
                                    completed()
                                })
                            }
                        }
                    }
                    
                    context("the external store returns an error") {
                        context("on the first batch request") {
                            it("calls the completion with no objects and an error") {
                                
                                mockServer.responses.append(MockFHIRServerResponse(error: FHIRError.error("Test error")))
                                
                                waitUntil { completed in
                                    store.fetchObjects(with: fetchObjects, completion: { (objects, error) in
                                        expect(objects).to(beNil())
                                        expect(error).toNot(beNil())
                                        expect((error as? FHIRError)?.description) == "Test error"
                                        completed()
                                    })
                                }
                            }
                        }
                        
                        context("on the second batch request") {
                            it("calls the completion with no objects and an error") {
                                
                                mockServer.responses.append(contentsOf:[FhirExternalStoreTestHelpers.generateServerResponse(with: Array(fetchObjects[0...9])), MockFHIRServerResponse(error: FHIRError.error("Test error"))])
                                
                                waitUntil { completed in
                                    store.fetchObjects(with: fetchObjects, completion: { (objects, error) in
                                        expect(objects).to(beNil())
                                        expect(error).toNot(beNil())
                                        expect((error as? FHIRError)?.description) == "Test error"
                                        completed()
                                    })
                                }
                            }
                        }
                    }
                }
            }
            
            context("if the add method is called") {
                var addObjects = [HDSExternalObjectProtocol]()
                var actualError: Error?
                var requestParams: [(String, FHIRRequestHandler)]?
                var requestCallCount = 0
                
                context("the objects array is empty") {
                    it("calls the completion with no error") {
                        waitUntil { completed in
                            store.add(objects: addObjects, completion: { (error) in
                                expect(error).to(beNil())
                                completed()
                            })
                        }
                    }
                }
                
                context("the objects array has a single object") {
                    context("the objects do not conform to ResourceContainerProtocol") {
                        beforeEach {
                            addObjects = [MockExternalObject()]
                            
                            waitUntil { completed in
                                store.add(objects: addObjects, completion: { (error) in
                                    actualError = error
                                    requestCallCount = mockServer.performRequestCallCount
                                    requestParams = mockServer.performRequestParams
                                    completed()
                                })
                            }
                        }
                        it("calls the completion with no error") {
                            expect(actualError).to(beNil())
                        }
                        
                        it("does not make a request to the FHIR server") {
                            expect(requestCallCount) == 0
                        }
                    }
                    
                    context("the server returns an error") {
                        beforeEach {
                            addObjects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 1, mockObservationFactory: self.mockObservationFactory)
                            mockServer.responses.append(MockFHIRServerResponse(error: FHIRError.error("Test error")))
                            
                            waitUntil { completed in
                                store.add(objects: addObjects, completion: { (error) in
                                    actualError = error
                                    requestCallCount = mockServer.performRequestCallCount
                                    requestParams = mockServer.performRequestParams
                                    completed()
                                })
                            }
                        }
                        it("calls the completion with an error") {
                            expect(actualError).toNot(beNil())
                            expect((actualError as? FHIRError)?.description) == "Test error"
                        }
                    }
                    
                    context("the objects do conform to ResourceContainerProtocol") {
                        beforeEach {
                            addObjects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 1, mockObservationFactory: self.mockObservationFactory)
                            mockServer.responses.append(MockFHIRServerResponse(resource: OperationOutcome()))
                            
                            waitUntil { completed in
                                store.add(objects: addObjects, completion: { (error) in
                                    actualError = error
                                    requestCallCount = mockServer.performRequestCallCount
                                    requestParams = mockServer.performRequestParams
                                    completed()
                                })
                            }
                        }
                        
                        it("calls the completion with no error") {
                            expect(actualError).to(beNil())
                        }
                        
                        it("makes a request to the FHIR server") {
                            expect(requestCallCount) == 1
                            expect(requestParams?.count) == 1
                            expect(requestParams![0].0) == "Observation"
                            expect(requestParams![0].1.method) == .POST
                            expect(requestParams![0].1.resource).toNot(beNil())
                        }
                    }
                    
                    context("the observation factory throws") {
                        it("calls completion with the error") {
                            addObjects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 1, mockObservationFactory: self.mockObservationFactory)
                            self.mockObservationFactory.shouldThrow = true
                            
                            waitUntil { completed in
                                store.add(objects: addObjects, completion: { (error) in
                                    expect(error).to(matchError(MockError.decodingError))
                                    completed()
                                })
                            }
                        }
                    }
                }
                
                context("the objects array has 5 objects") {
                    context("the third object does not conform to ResourceContainerProtocol") {
                        beforeEach {
                            addObjects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 4, mockObservationFactory: self.mockObservationFactory)
                            addObjects.insert(MockExternalObject(), at: 2)
                            mockServer.responses.append(contentsOf:[MockFHIRServerResponse(resource: OperationOutcome()), MockFHIRServerResponse(resource: OperationOutcome()), MockFHIRServerResponse(resource: OperationOutcome()), MockFHIRServerResponse(resource: OperationOutcome()), MockFHIRServerResponse(resource: OperationOutcome())])
                            
                            waitUntil { completed in
                                store.add(objects: addObjects, completion: { (error) in
                                    actualError = error
                                    requestCallCount = mockServer.performRequestCallCount
                                    requestParams = mockServer.performRequestParams
                                    completed()
                                })
                            }
                        }
                        it("calls the completion with no error") {
                            expect(actualError).to(beNil())
                        }
                        
                        it("makes 4 requests to the FHIR server") {
                            expect(requestCallCount) == 4
                        }
                    }
                    
                    context("the server returns an error") {
                        beforeEach {
                            addObjects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: self.mockObservationFactory)
                            mockServer.responses.append(MockFHIRServerResponse(error: FHIRError.error("Test error")))
                            
                            waitUntil { completed in
                                store.add(objects: addObjects, completion: { (error) in
                                    actualError = error
                                    requestCallCount = mockServer.performRequestCallCount
                                    requestParams = mockServer.performRequestParams
                                    completed()
                                })
                            }
                        }
                        it("calls the completion with an error") {
                            expect(actualError).toNot(beNil())
                            expect((actualError as? FHIRError)?.description) == "Test error"
                        }
                    }
                    
                    context("the objects do conform to ResourceContainerProtocol") {
                        beforeEach {
                            addObjects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: self.mockObservationFactory)
                            mockServer.responses.append(contentsOf:[MockFHIRServerResponse(resource: OperationOutcome()), MockFHIRServerResponse(resource: OperationOutcome()), MockFHIRServerResponse(resource: OperationOutcome()), MockFHIRServerResponse(resource: OperationOutcome()), MockFHIRServerResponse(resource: OperationOutcome())])
                            
                            waitUntil { completed in
                                store.add(objects: addObjects, completion: { (error) in
                                    actualError = error
                                    requestCallCount = mockServer.performRequestCallCount
                                    requestParams = mockServer.performRequestParams
                                    completed()
                                })
                            }
                        }
                        
                        it("calls the completion with no error") {
                            expect(actualError).to(beNil())
                        }
                        
                        it("makes a request to the FHIR server") {
                            expect(requestCallCount) == 5
                            expect(requestParams?.count) == 5
                            for i in 0..<5 {
                                expect(requestParams![i].0) == "Observation"
                                expect(requestParams![i].1.method) == .POST
                                expect(requestParams![i].1.resource).toNot(beNil())
                            }
                        }
                    }
                    
                    context("the observation factory throws") {
                        it("calls completion with the error") {
                            addObjects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 5, mockObservationFactory: self.mockObservationFactory)
                            self.mockObservationFactory.shouldThrow = true
                            
                            waitUntil { completed in
                                store.add(objects: addObjects, completion: { (error) in
                                    expect(error).to(matchError(MockError.decodingError))
                                    completed()
                                })
                            }
                        }
                    }
                }
            }
            
            context("if the update method is called") {
                var updateObjects = [HDSExternalObjectProtocol]()
                var actualError: Error?
                var requestParams: [(String, FHIRRequestHandler)]?
                var requestCallCount = 0
                
                context("the objects array is empty") {
                    it("calls the completion with no error") {
                        waitUntil { completed in
                            store.update(objects: [], completion: { (error) in
                                expect(error).to(beNil())
                                completed()
                            })
                        }
                    }
                }
                
                context("the objects array has a single object") {
                    context("the objects do conform to ResourceContainerProtocol") {
                        beforeEach {
                            updateObjects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 1, mockObservationFactory: self.mockObservationFactory, addId: true)
                            mockServer.responses.append(MockFHIRServerResponse(resource: OperationOutcome()))
                            
                            waitUntil { completed in
                                store.update(objects: updateObjects, completion: { (error) in
                                    actualError = error
                                    requestCallCount = mockServer.performRequestCallCount
                                    requestParams = mockServer.performRequestParams
                                    completed()
                                })
                            }
                        }
                        
                        it("calls the completion with no error") {
                            expect(actualError).to(beNil())
                        }
                        
                        it("makes a request to the FHIR server") {
                            expect(requestCallCount) == 1
                            expect(requestParams?.count) == 1
                            expect(requestParams![0].0) == "Observation/00000000-0000-0000-0000-000000000000"
                            expect(requestParams![0].1.method) == .PUT
                            expect(requestParams![0].1.resource).toNot(beNil())
                        }
                    }
                }
            }
            
            context("if the delete method is called") {
                var deleteObjects = [HDSExternalObjectProtocol]()
                var actualError: Error?
                var requestParams: [(String, FHIRRequestHandler)]?
                var requestCallCount = 0
                
                context("the objects array is empty") {
                    it("calls the completion with no error") {
                        waitUntil { completed in
                            store.delete(deletedObjects: [], completion: { error in
                                expect(error).to(beNil())
                                completed()
                            })
                        }
                    }
                }
                
                context("the objects array has a single object") {
                    context("the objects do conform to ResourceContainerProtocol") {
                        beforeEach {
                            deleteObjects = FhirExternalStoreTestHelpers.generateRequestObjects(count: 1, mockObservationFactory: self.mockObservationFactory, addId: true)
                            mockServer.responses.append(MockFHIRServerResponse(resource: OperationOutcome()))
                            
                            waitUntil { completed in
                                store.delete(deletedObjects: deleteObjects, completion: { (error) in
                                    actualError = error
                                    requestCallCount = mockServer.performRequestCallCount
                                    requestParams = mockServer.performRequestParams
                                    completed()
                                })
                            }
                        }
                        
                        it("calls the completion with no error") {
                            expect(actualError).to(beNil())
                        }
                        
                        it("makes a request to the FHIR server") {
                            expect(requestCallCount) == 1
                            expect(requestParams?.count) == 1
                            expect(requestParams![0].0) == "Observation/00000000-0000-0000-0000-000000000000"
                            expect(requestParams![0].1.method) == .DELETE
                        }
                    }
                }
            }
        }
    }
}
