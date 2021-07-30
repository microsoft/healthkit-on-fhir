//
//  RKtoFHIR.swift
//  researchKitOnFhir
//

import Foundation
import SMART
import ResearchKit

public class RKtoFHIRConverter {
    
    init() {
        // do nothing
    }
    
    func RKQuestionResponseToFHIR (results: ORKTaskViewController) -> QuestionnaireResponse {
        let taskResult = results.result.results
        let questionnaireResponse = QuestionnaireResponse()
        
        var FHIRQuestionResponses = [QuestionnaireResponseItem]()
        
        if taskResult != nil {
            
            for stepResults in taskResult! as! [ORKStepResult]
            {
                if stepResults.results != nil {
                    
                    for result in stepResults.results!
                    {
                        var newQuestionResponse: QuestionnaireResponseItem
                        let type = FHIRtoRKConverter.FHIRQuestionMap[result.identifier]?.type?.rawValue
                        
                        switch(type) {
                        
                        case "text", "string":
                            newQuestionResponse = convertTextResponse(result: result)
                            
                        case "integer":
                            let integerConverter = IntegerResponseBuilder(result: result)
                            newQuestionResponse = integerConverter.convertResponse()
                            
                        case "decimal":
                            let decimalConverter = DecimalResponseBuilder(result: result)
                            newQuestionResponse = decimalConverter.convertResponse()
                            
                        case "boolean":
                            let booleanConverter = BooleanResponseBuilder(result: result)
                            newQuestionResponse = booleanConverter.convertResponse()
                            
                        case "time","dateTime", "date":
                            let dateTimeConverter = DateTimeResponseBuilder(result: result)
                            newQuestionResponse = dateTimeConverter.convertResponse(type: type!)
                            
                        case "choice":
                            let choiceConverter = ChoiceResponseBuilder(result: result)
                            newQuestionResponse = choiceConverter.convertResponse()
                            
                        default:
                            newQuestionResponse = convertTextResponse(result: result)
                        }
                        if newQuestionResponse.answer != nil {
                            FHIRQuestionResponses += [newQuestionResponse]
                        }
                    }
                }
            }
        }
        questionnaireResponse.item = FHIRQuestionResponses
        questionnaireResponse.status = QuestionnaireResponseStatus.completed
        return questionnaireResponse
    }
    
    func convertTextResponse(result: ORKResult) -> QuestionnaireResponseItem {
        let textConverter = TextStringResponseBuilder(result: result)
        return textConverter.convertResponse()
    }
    
    
    
   
}
