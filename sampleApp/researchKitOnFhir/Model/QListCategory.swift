//
//  QListCategory.swift
//  researchKitOnFhir
//
//  Created by admin on 7/22/21.
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
