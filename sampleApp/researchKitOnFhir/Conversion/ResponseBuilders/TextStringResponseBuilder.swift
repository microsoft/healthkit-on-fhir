//
//  TextStringResponseBuilder.swift
//  researchKitOnFhir
//

import Foundation
import FHIR
import ResearchKit

public class TextStringResponseBuilder: FHIRResponseBuilder {
    
    public func convertResponse() -> QuestionnaireResponseItem {
        
        let newResult = self.result as! ORKTextQuestionResult
        let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
        
        if newResult.textAnswer != nil {
            let newAnswerAsFHIRString = FHIRString(newResult.textAnswer!)
            newQuestionResponseAnswer.valueString = newAnswerAsFHIRString
            newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
            if newQuestionResponseAnswer.valueString != nil && newQuestionResponse.answer != nil {
                newQuestionResponse.answer! += [newQuestionResponseAnswer]
            }
        }
        return newQuestionResponse
    }
    
}
