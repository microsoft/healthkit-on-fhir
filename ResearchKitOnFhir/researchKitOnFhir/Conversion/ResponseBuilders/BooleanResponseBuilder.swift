//
//  BooleanResponseBuilder.swift
//  researchKitOnFhir
//

import Foundation
import FHIR
import ResearchKit

public class BooleanResponseBuilder: FHIRResponseBuilder {
    
    public func convertResponse() -> QuestionnaireResponseItem {
        
        let newResult = result as! ORKBooleanQuestionResult
        let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
        
        if newResult.booleanAnswer != nil {
            let newAnswerAsFHIRBoolean = FHIRBool(booleanLiteral: (newResult.booleanAnswer != nil))
            newQuestionResponseAnswer.valueBoolean = newAnswerAsFHIRBoolean
            
            newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
            if newQuestionResponseAnswer.valueBoolean != nil && newQuestionResponse.answer != nil {
                newQuestionResponse.answer! += [newQuestionResponseAnswer]
            }
        }
        return newQuestionResponse
    }
}
