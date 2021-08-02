//
//  SecretStoreError.swift
//  researchKitOnFhir
//
//  Created by admin on 7/26/21.
//

import Foundation

public enum SecretStoreError : Error {
    case invalidKeyValue(key: String)
    case invalidSecretValue(value: String)
    case malformedSecretData
    case fetchError(status: OSStatus)
    case deleteError(status: OSStatus)
    case saveError(status: OSStatus)
}
