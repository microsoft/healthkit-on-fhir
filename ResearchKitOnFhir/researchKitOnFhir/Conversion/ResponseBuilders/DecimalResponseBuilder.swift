//
//  DecimalResponseBuilder.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation
import FHIR
import ResearchKit

public class DecimalResponseBuilder: FHIRResponseBuilder {
    
    public func convertResponse() -> QuestionnaireResponseItem {
        
        let newResult = result as? ORKNumericQuestionResult
        let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
        
        if let numericAnswer = newResult?.numericAnswer as? Decimal {
            let newAnswerAsFHIRDecimal = FHIRDecimal(numericAnswer)
            newQuestionResponseAnswer.valueDecimal = newAnswerAsFHIRDecimal
            
            newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
            if newQuestionResponseAnswer.valueDecimal != nil && newQuestionResponse.answer != nil {
                newQuestionResponse.answer! += [newQuestionResponseAnswer]
            }
        }
        return newQuestionResponse
    }
}
