//
//  FhirExternalStoreTestHelpers.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import FHIR
import HealthKit

public class FhirExternalStoreTestHelpers {
    public static func generateRequestObjects(count: Int, mockObservationFactory: MockObservationFactory, addId: Bool = false) -> [MockObservationContainer] {
        var objects = [MockObservationContainer]()
        let converter = Converter(converterMap: [Observation.resourceType : mockObservationFactory])
        
        for _ in 0..<count {
            objects.append(MockObservationContainer(object: HKQuantitySample(type: HKObjectType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit.init(from: "count"), doubleValue: 2), start: Date(), end: Date()), converter: converter))
            
            if addId {
                if let container = objects.last {
                    let resource = try! container.getResource()
                    resource.id = FHIRString("00000000-0000-0000-0000-000000000000")
                    container.setResource(resource: resource)
                }
            }
        }
        
        return objects
    }
    
    public static func generateServerResponse(with objects: [MockObservationContainer]) -> MockFHIRServerResponse {
        let bundle = FHIR.Bundle.init(type: .searchset)
        
        for object in objects {
            let entry = BundleEntry()
            let observation: Observation = try! object.getResource() as! Observation
            observation.status = .final
            entry.resource = observation
            
            if bundle.entry == nil {
                bundle.entry = [entry]
            } else {
                bundle.entry!.append(entry)
            }
        }
        
        return MockFHIRServerResponse(resource: bundle)
    }
}
