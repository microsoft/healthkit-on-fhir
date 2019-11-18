//
//  IomtFhirExternalStoreDelegateTests.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Quick
import Nimble
import IomtFhirClient
import HealthDataSync

class IomtFhirExternalStoreDelegateSpec: QuickSpec {
    let testConnectionString = "Endpoint=sb://test.servicebus.windows.net/;SharedAccessKeyName=TESTKEYNAME;SharedAccessKey=TESTTOKEN;EntityPath=TESTPATH"
    
    override func spec() {
        describe("IomtFhirExternalStoreDelegate") {
            var store: IomtFhirExternalStore!
            let mockSender = MockEventDataSender()
            let delegate = MockExternalStoreDelegate()
            beforeEach {
                let iomtFhirClient = try! IomtFhirClient.CreateFromConnectionString(connectionString: self.testConnectionString)
                iomtFhirClient.sender = mockSender
                mockSender.parameters = nil
                mockSender.shouldThrow = false
                store = IomtFhirExternalStore(iomtFhirClient: iomtFhirClient)
                store.delegate = delegate
                delegate.shouldAddParams = nil
                delegate.addCompleteParams = nil
            }
            
            context("if the add method is called on the event hubs connection") {
                context("with no objects") {
                    it("does not receive calls to willSend or sendComplete") {
                        waitUntil { completed in
                            store.add(objects: [], completion: { error in
                                completed()
                            })
                        }
                        expect(delegate.shouldAddParams).to(beNil())
                        expect(delegate.addCompleteParams).to(beNil())
                    }
                }
                
                context("with an object that throws during serialization") {
                    it("does not receive a call to willSend and sendComplete is called with the expected error") {
                        waitUntil { completed in
                            let message = MockIomtFhirMessage()
                            message.shouldThrowOnDecode = true
                            store.add(objects: [message], completion: { error in
                                completed()
                            })
                        }
                        expect(delegate.shouldAddParams).to(beNil())
                        expect(delegate.addCompleteParams?.1).to(beFalse())
                        expect(delegate.addCompleteParams?.2).to(matchError(MockError.decodingError))
                    }
                }
                
                context("with an object and the event hubs client throws") {
                    it("receives a call to willSend with a valid EventData object and sendComplete is called with the expected error") {
                        let message = MockIomtFhirMessage()
                        message.value = 23
                        waitUntil { completed in
                            mockSender.shouldThrow = true
                            store.add(objects: [message], completion: { error in
                                completed()
                            })
                        }
                        expect(String(data: delegate.shouldAddParams!.0.data, encoding: .utf8)) == "{\"value\":23,\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"
                        expect(delegate.addCompleteParams?.1).to(beFalse())
                        expect(delegate.addCompleteParams?.2).to(matchError(MockError.sendError))
                    }
                }
                
                context("with an object and the event hubs client returns an error") {
                    it("receives a call to willSend with a valid EventData object and sendComplete is called with the expected error") {
                        let message = MockIomtFhirMessage()
                        message.value = 88
                        waitUntil { completed in
                            store.add(objects: [message], completion: { error in
                                completed()
                            })
                            mockSender.parameters?.1(false, MockError.sendError)
                        }
                        expect(String(data: delegate.shouldAddParams!.0.data, encoding: .utf8)) == "{\"value\":88,\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"
                        expect(delegate.addCompleteParams?.1).to(beFalse())
                        expect(delegate.addCompleteParams?.2).to(matchError(MockError.sendError))
                    }
                }
                
                context("with an object that inherits from IomtFhirMessageBase") {
                    it("receives calls to willSend and sendComplete with a valid EventData object and sendComplete is called with no error") {
                        let message = MockIomtFhirMessage()
                        message.value = 44
                        waitUntil { completed in
                            store.add(objects: [message], completion: { error in
                                completed()
                            })
                            mockSender.parameters?.1(true, nil)
                        }
                        let expected = "{\"value\":44,\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"
                        expect(String(data: delegate.shouldAddParams!.0.data, encoding: .utf8)) == expected
                        expect(String(data: delegate.addCompleteParams!.0[0].data, encoding: .utf8)) == expected
                        expect(delegate.addCompleteParams?.1).to(beTrue())
                        expect(delegate.addCompleteParams?.2).to(beNil())
                    }
                }
                
                context("and the delegate returns false for the shouldSend call") {
                    it("receives calls to willSend and sendComplete with a valid EventData object and sendComplete is called with no error") {
                        delegate.shouldAddCompletionValue = (false, MockError.sendError)
                        let message = MockIomtFhirMessage()
                        message.value = 99
                        waitUntil { completed in
                            store.add(objects: [message], completion: { error in
                                expect(error).to(matchError(MockError.sendError))
                                completed()
                            })
                        }
                        let expected = "{\"value\":99,\"endDate\":\"1970-01-01T00:00:00Z\",\"startDate\":\"1970-01-01T00:00:00Z\",\"uuid\":\"00000000-0000-0000-0000-000000000000\"}"
                        expect(String(data: delegate.shouldAddParams!.0.data, encoding: .utf8)) == expected
                        expect(delegate.addCompleteParams?.0.first).to(beNil())
                        expect(delegate.addCompleteParams?.1).to(beFalse())
                        expect(delegate.addCompleteParams?.2).to(matchError(MockError.sendError))
                    }
                }
            }
        }
    }
}
