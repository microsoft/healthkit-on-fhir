//
//  TextStringResponseBuilder.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation
import FHIR
import ResearchKit

public class TextStringResponseBuilder: FHIRResponseBuilder {
    
    public func convertResponse() -> QuestionnaireResponseItem {
        
        let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
        
        // set default to no response in case result is nil
        newQuestionResponseAnswer.valueString = FHIRString(ResponseMessage.noResponse)
        
        if let newResult = self.result as? ORKTextQuestionResult {
            if let textAnswer = newResult.textAnswer {
                let newAnswerAsFHIRString = FHIRString(textAnswer)
                newQuestionResponseAnswer.valueString = newAnswerAsFHIRString
            }
        }
        
        newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
        
        if newQuestionResponseAnswer.valueString != nil && newQuestionResponse.answer != nil {
            newQuestionResponse.answer! += [newQuestionResponseAnswer]
        }
        
        return newQuestionResponse
    }
    
}
