//
//  IntegerResponseBuilder.swift
//  researchKitOnFhir
//

import Foundation
import FHIR
import ResearchKit

public class IntegerResponseBuilder: FHIRResponseBuilder {
    
    public func convertResponse() -> QuestionnaireResponseItem {
        
        let newResult = result as! ORKNumericQuestionResult
        let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
        
        if newResult.numericAnswer != nil {
            let newAnswerAsFHIRInteger = FHIRInteger(newResult.numericAnswer as! Int32)
            newQuestionResponseAnswer.valueInteger = newAnswerAsFHIRInteger
            
            newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
            if newQuestionResponseAnswer.valueInteger != nil && newQuestionResponse.answer != nil {
                newQuestionResponse.answer! += [newQuestionResponseAnswer]
            }
        }
        return newQuestionResponse
    }
    
}
