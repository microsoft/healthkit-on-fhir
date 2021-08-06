//
//  QListCategory.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation

class QListCategory {
    
    var completionHeader: String?
    var questionnairesDisplayed: [QuestionnaireType]?
    
    init(completion: String, questionnaires: [QuestionnaireType]) {
        completionHeader = completion
        questionnairesDisplayed = questionnaires
    }
    
}
