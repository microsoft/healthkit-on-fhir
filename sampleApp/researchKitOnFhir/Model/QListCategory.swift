//
//  QListCategory.swift
//  researchKitOnFhir
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
