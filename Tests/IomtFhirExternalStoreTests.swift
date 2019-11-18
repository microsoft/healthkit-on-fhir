//
//  IomtFhirExternalStoreTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Quick
import Nimble
import IomtFhirClient
import HealthDataSync

class IomtFhirExternalStoreSpec: QuickSpec {
    let testConnectionString = "Endpoint=sb://test.servicebus.windows.net/;SharedAccessKeyName=TESTKEYNAME;SharedAccessKey=TESTTOKEN;EntityPath=TESTPATH"
    
    override func spec() {
        describe("IomtFhirExternalStore") {
            
            var store: IomtFhirExternalStore!
            let mockSender = MockEventDataSender()
            let mockDelegate = MockExternalStoreDelegate()
            beforeEach {
                let iomtFhirClient = try! IomtFhirClient.CreateFromConnectionString(connectionString: self.testConnectionString)
                iomtFhirClient.sender = mockSender
                mockSender.parameters = nil
                mockSender.shouldThrow = false
                store = IomtFhirExternalStore(iomtFhirClient: iomtFhirClient)
                store.delegate = mockDelegate
            }
            
            context("if the fetchObjects method is called") {
                it("calls the completion with no objects and no error") {
                    waitUntil { completed in
                        store.fetchObjects(with: [], completion: { (objects, error) in
                            expect(objects).to(beNil())
                            expect(error).to(beNil())
                            completed()
                        })
                    }
                }
            }
            
            context("if the update method is called") {
                it("calls the completion with no error") {
                    waitUntil { completed in
                        store.update(objects: [], completion: { error in
                            expect(error).to(beNil())
                            completed()
                        })
                    }
                }
            }
            
            context("if the delete method is called") {
                it("calls the completion with no error") {
                    waitUntil { completed in
                        store.delete(deletedObjects: [], completion: { error in
                            expect(error).to(beNil())
                            completed()
                        })
                    }
                }
            }
            
            context("if the add method is called") {
                context("with no objects") {
                    it("calls the completion with no error") {
                        waitUntil { completed in
                            store.add(objects: [], completion: { error in
                                expect(error).to(beNil())
                                completed()
                            })
                        }
                    }
                }
                
                context("with an object that throws during serialization") {
                    it("calls the completion with the expected error") {
                        waitUntil { completed in
                            let message = MockIomtFhirMessage()
                            message.shouldThrowOnDecode = true
                            store.add(objects: [message], completion: { error in
                                expect(error).to(matchError(MockError.decodingError))
                                completed()
                            })
                        }
                    }
                }
                
                context("with an object and the event hubs client throws") {
                    it("calls the completion with the expected error") {
                        waitUntil { completed in
                            let message = MockIomtFhirMessage()
                            mockSender.shouldThrow = true
                            store.add(objects: [message], completion: { error in
                                expect(error).to(matchError(MockError.sendError))
                                completed()
                            })
                        }
                    }
                }
                
                context("with an object that does not inherit from IomtFhirMessageBase") {
                    it("calls the event hubs client with no data") {
                        store.add(objects: [MockExternalObject()], completion: { error in })
                        expect(mockSender.parameters?.0.count) == 0
                    }
                }
                
                context("with an object that inherits from IomtFhirMessageBase") {
                    it("calls the event hubs client with a valid EventData object") {
                        waitUntil { completed in
                            let message = MockIomtFhirMessage()
                            message.value = 99
                            store.add(objects: [message], completion: { error in
                                let eventData = mockSender.parameters!.0
                                expect(eventData.count) == 1
                                expect(String(data: eventData[0].data, encoding: .utf8)) == "{\"value\":99,\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"
                                completed()
                            })
                            
                            mockSender.parameters!.1(true, nil)
                        }
                    }
                    
                    context("with no delegate") {
                        it("calls the event hubs client with a valid EventData object") {
                            store.delegate = nil
                            mockSender.completion = (true, nil)
                            waitUntil { completed in
                                let message = MockIomtFhirMessage()
                                message.value = 88
                                store.add(objects: [message], completion: { error in
                                    let eventData = mockSender.parameters!.0
                                    expect(eventData.count) == 1
                                    expect(String(data: eventData[0].data, encoding: .utf8)) == "{\"value\":88,\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"
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

