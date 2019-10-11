// swift-tools-version:5.0
//  Package.swift
//  HealthKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import PackageDescription

let package = Package(
    name: "HealthKitOnFhir",
	platforms: [
        .iOS(.v11)
	],
    products: [
        .library(
            name: "HealthKitOnFhir",
            targets: ["HealthKitOnFhir"]),
    ],
    dependencies: [
        .package(url: "https://github.com/smart-on-fhir/Swift-FHIR", from: "4.2.0"),
        .package(url: "git@github.com:microsoft/iomt-fhir-client", .branch("master")),
        .package(url: "git@github.com:microsoft/health-data-sync", .revision("master")),
        .package(url: "git@github.com:microsoft/healthkit-to-fhir", .branch("master")),
    ],
    targets: [
        .target(
            name: "HealthKitOnFhir",
            dependencies: ["FHIR", "IomtFhirClient", "HealthDataSync", "HealthKitToFhir"],
            path: "Sources",
            sources: ["IomtFhir", "Fhir"]),
    ]
)
