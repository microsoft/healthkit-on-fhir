//
//  BooleanResponseBuilder.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation
import FHIR
import ResearchKit

public class BooleanResponseBuilder: FHIRResponseBuilder {
    
    public func convertResponse() -> QuestionnaireResponseItem {
        
        let newResult = result as? ORKBooleanQuestionResult
        let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
        
        if let booleanAnswer = newResult?.booleanAnswer {
            let newAnswerAsFHIRBoolean = FHIRBool(booleanLiteral: booleanAnswer.boolValue)
            newQuestionResponseAnswer.valueBoolean = newAnswerAsFHIRBoolean
            
            newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
            if newQuestionResponseAnswer.valueBoolean != nil && newQuestionResponse.answer != nil {
                newQuestionResponse.answer! += [newQuestionResponseAnswer]
            }
        }
        return newQuestionResponse
    }
}
