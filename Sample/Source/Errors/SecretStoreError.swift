//
//  SecretStoreError.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
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
