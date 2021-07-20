//
//  QuestionnaireType.swift
//  researchKitOnFhir
//
//  Created by admin on 7/18/21.
//

import Foundation
import ResearchKit
import SMART

public class QuestionnaireType {
    
    var FHIRquestionnaire: Questionnaire
    var questionnaireComplete: Bool
    
    init(questionnaire: Questionnaire, complete: Bool) {
        FHIRquestionnaire = questionnaire
        questionnaireComplete = complete
    }
    
}
