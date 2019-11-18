//
//  ServerExtensions.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import SMART

extension Server {
    public func tokenClaims() -> Dictionary<String, Any>? {
        do {
            if let claimsString = claimsString(),
                let decodedData = Data(base64Encoded: claimsString),
                let dictionary = try JSONSerialization.jsonObject(with: decodedData, options:[]) as? [String : Any] {
                return dictionary
            }
        } catch {
            
        }
        
        return nil
    }
    
    public func fetchAuthenticatedPatient(completion: @escaping (Patient?, Error?) -> Void ) {
        if let claims = tokenClaims(),
            let issuer = claims["iss"],
            let subject = claims["sub"] {
            Patient.search(["identifier": "\(issuer)|\(subject)"])
                .perform(self) { (bundle, error) in
                    guard error == nil else {
                        completion(nil, error)
                        return
                    }
                    
                    if let bundleEntry = bundle?.entry?.first,
                        let patient = bundleEntry.resource as? Patient {
                        // Complete with the patient resource.
                        completion(patient, nil)
                    } else {
                        // No Patient Resource exists for this user.
                        completion(nil, nil)
                    }
            }
        }
    }
    
    private func claimsString() -> String? {
        // Ensure the token is not nil.
        if let token = self.idToken {
            // Separate the token components.
            let tokenComponents = token.split(separator: ".")
            if tokenComponents.count > 1 {
                let claimsString = String(tokenComponents[1])
                if claimsString.count % 4 > 0 {
                    return claimsString.padding(toLength: claimsString.count + 4 - (claimsString.count % 4), withPad: "=", startingAt: 0)
                }
                return claimsString
            }
        }
        
        return nil
    }
}
