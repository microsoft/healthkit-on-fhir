//
//  MockError.swift
//  HealthKitOnFhir_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public enum MockError : Error {
    case decodingError
    case sendError
    case converterError
    case factoryError
    case delegateError
}
