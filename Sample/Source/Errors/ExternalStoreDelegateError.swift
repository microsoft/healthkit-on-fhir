//
//  ExternalStoreDelegateError.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public enum ExternalStoreDelegateError : Error {
    case patientDoesNotExist
    case hkObjectNil
    case eventDataSerializationError
    case deviceCreationFalied
}
