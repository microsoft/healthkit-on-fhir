//
//  QuestionnaireType.swift
//  researchKitOnFhir
//
//  Created by admin on 7/18/21.
//

import Foundation
import ResearchKit
import SMART

class QuestionnaireType {
    
    var FHIRquestionnaire: Questionnaire
    var questionnaireComplete: Bool
    
    init(questionnaire: Questionnaire) {
        FHIRquestionnaire = questionnaire
        questionnaireComplete = false
    }
    
}
