//
//  IntegerResponseBuilder.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation
import FHIR
import ResearchKit

public class IntegerResponseBuilder: FHIRResponseBuilder {
    
    public func convertResponse() -> QuestionnaireResponseItem {
        
        let newResult = result as? ORKNumericQuestionResult
        let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
        
        if let numericAnswer = newResult?.numericAnswer as? Int32 {
            let newAnswerAsFHIRInteger = FHIRInteger(numericAnswer)
            newQuestionResponseAnswer.valueInteger = newAnswerAsFHIRInteger
            
            newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
            if newQuestionResponseAnswer.valueInteger != nil && newQuestionResponse.answer != nil {
                newQuestionResponse.answer! += [newQuestionResponseAnswer]
            }
        }
        return newQuestionResponse
    }
    
}
