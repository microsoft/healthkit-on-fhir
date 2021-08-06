//
//  ExternalStoreDelegateError.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation

public enum ExternalStoreDelegateError : Error {
    case noQuestionnairesInServer
    case noValidTaskInServer
}
