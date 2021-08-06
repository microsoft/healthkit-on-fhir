//
//  ChoiceResponseBuilder.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation
import FHIR
import ResearchKit

public class ChoiceResponseBuilder: FHIRResponseBuilder {
    
    public func convertResponse() -> QuestionnaireResponseItem {
        
        let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
        
        if let newResult = result as? ORKChoiceQuestionResult {
            
            var newAnswerAsFHIRString: FHIRString
            
            if newResult.answer != nil {
                if let answerArray = newResult.answer as? NSArray {
                    if answerArray.count > 0 {
                        // FHIR standard only allows for one answer to be selected from multiple choice question
                        newAnswerAsFHIRString = FHIRString(answerArray[0] as? String ?? ResponseMessage.noResponse)
                        
                        newQuestionResponseAnswer.valueString = newAnswerAsFHIRString
                        
                        newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                        
                        if newQuestionResponse.answer != nil {
                            newQuestionResponse.answer! += [newQuestionResponseAnswer]
                        }
                    }
                }
            }
        }
        
        return newQuestionResponse
    }
}
