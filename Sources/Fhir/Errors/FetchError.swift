//
//  FetchError.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public enum FetchError : Error {
    case invalidResourceType
    case resourceTypeMismatch
}
