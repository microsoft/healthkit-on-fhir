//
//  DecimalResponseBuilder.swift
//  researchKitOnFhir
//

import Foundation
import FHIR
import ResearchKit

public class DecimalResponseBuilder: FHIRResponseBuilder {
    
    public func convertResponse() -> QuestionnaireResponseItem {
        
        let newResult = result as! ORKNumericQuestionResult
        let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
        
        if newResult.numericAnswer != nil {
            let newAnswerAsFHIRDecimal = FHIRDecimal(newResult.numericAnswer as! Decimal)
            newQuestionResponseAnswer.valueDecimal = newAnswerAsFHIRDecimal
            
            newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
            if newQuestionResponseAnswer.valueDecimal != nil && newQuestionResponse.answer != nil {
                newQuestionResponse.answer! += [newQuestionResponseAnswer]
            }
        }
        return newQuestionResponse
    }
}
