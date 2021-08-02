//
//  ChoiceResponseBuilder.swift
//  researchKitOnFhir
//

import Foundation
import FHIR
import ResearchKit

public class ChoiceResponseBuilder: FHIRResponseBuilder {
    
    public func convertResponse() -> QuestionnaireResponseItem {
        
        let newResult = result as! ORKChoiceQuestionResult
        let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
        
        if newResult.answer != nil {
            let answerArray = newResult.answer as! NSArray
            
            var newAnswerAsFHIRString = FHIRString("no response")
            
            if answerArray.count > 0 {
                // FHIR standard only allows for one answer to be selected from multiple choice question
                newAnswerAsFHIRString.string = answerArray[0] as! String
            }
            
            newQuestionResponseAnswer.valueString = newAnswerAsFHIRString
            
            newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
            
            if newQuestionResponseAnswer.valueString != nil && newQuestionResponse.answer != nil {
                newQuestionResponse.answer! += [newQuestionResponseAnswer]
            }
        }
        
        return newQuestionResponse
    }
}
