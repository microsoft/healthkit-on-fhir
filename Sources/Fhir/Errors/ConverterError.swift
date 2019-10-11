//
//  ConverterError.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public enum ConverterError : Error {
    case requiredConverterNotProvided
    case noObjectToConvert
    case converterNotFound
    case notSupported
}
