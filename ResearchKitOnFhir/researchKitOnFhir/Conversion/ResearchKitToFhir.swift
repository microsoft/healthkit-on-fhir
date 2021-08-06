//
//  ResearchKitToFhir.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation
import SMART
import ResearchKit

struct ResponseMessage {
    static let noResponse = "no response given"
}

public class ResearchKitToFhirConverter {
    
    func researchKitQuestionResponseToFhir (results: ORKTaskViewController) -> QuestionnaireResponse {
        
        let questionnaireResponse = QuestionnaireResponse()
        
        var FHIRQuestionResponses = [QuestionnaireResponseItem]()
        
        if let taskResult = results.result.results as? [ORKStepResult] {
            
            for stepResults in taskResult
            {
                if let stepResultResults = stepResults.results {
                    
                    for result in stepResultResults
                    {
                        var newQuestionResponse: QuestionnaireResponseItem
                        
                        if let type = FhirToResearchKitConverter.fhirQuestionMap[result.identifier]?.type?.rawValue {
                            switch(type) {
                            
                            case fhirTypes.text, fhirTypes.string:
                                newQuestionResponse = convertTextResponse(result: result)
                                
                            case fhirTypes.integer:
                                let integerConverter = IntegerResponseBuilder(result: result)
                                newQuestionResponse = integerConverter.convertResponse()
                                
                            case fhirTypes.decimal:
                                let decimalConverter = DecimalResponseBuilder(result: result)
                                newQuestionResponse = decimalConverter.convertResponse()
                                
                            case fhirTypes.boolean:
                                let booleanConverter = BooleanResponseBuilder(result: result)
                                newQuestionResponse = booleanConverter.convertResponse()
                                
                            case fhirTypes.time,fhirTypes.dateTime, fhirTypes.date:
                                let dateTimeConverter = DateTimeResponseBuilder(result: result)
                                newQuestionResponse = dateTimeConverter.convertResponse(type: type)
                                
                            case fhirTypes.choice:
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
