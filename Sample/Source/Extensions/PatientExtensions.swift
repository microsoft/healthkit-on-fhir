//
//  PatientExtensions.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import SMART

extension Patient {
    public static func createPatient(given: String, family: String, dateOfBirth: Date, gender: AdministrativeGender) -> Patient? {
        let humanName = HumanName()
        humanName.given = [FHIRString(given)]
        humanName.family = FHIRString(family)
        
        let patient = Patient()
        patient.name = [humanName]
        patient.birthDate = dateOfBirth.fhir_asDate()
        patient.gender = gender
        
        return patient
    }
}
