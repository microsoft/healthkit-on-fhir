//
//  RKtoFHIR.swift
//  researchKitOnFhir
//
//  Created by admin on 7/13/21.
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
                        let resultLinkID = FHIRString(result.identifier)
                        let newQuestionResponse = QuestionnaireResponseItem(linkId: resultLinkID)
                        let type = FHIRtoRKConverter.FHIRQuestionMap[result.identifier]?.type?.rawValue
                        
                        switch(type) {
                        
                        case "text", "string":
                            let newResult = result as! ORKTextQuestionResult
                            let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                            
                            if newResult.textAnswer != nil {
                                let newAnswerAsFHIRString = FHIRString(newResult.textAnswer!)
                                newQuestionResponseAnswer.valueString = newAnswerAsFHIRString
                                newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                                if newQuestionResponseAnswer.valueString != nil && newQuestionResponse.answer != nil {
                                    newQuestionResponse.answer! += [newQuestionResponseAnswer]
                                }
                            }
                            
                        case "integer":
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
                            
                        case "decimal":
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
                            
                        case "boolean":
                            let newResult = result as! ORKBooleanQuestionResult
                            let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                            
                            if newResult.booleanAnswer != nil {
                                let newAnswerAsFHIRBoolean = FHIRBool(booleanLiteral: (newResult.booleanAnswer != nil))
                                newQuestionResponseAnswer.valueBoolean = newAnswerAsFHIRBoolean
                                
                                newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                                if newQuestionResponseAnswer.valueBoolean != nil && newQuestionResponse.answer != nil {
                                    newQuestionResponse.answer! += [newQuestionResponseAnswer]
                                }
                            }
                            
                        case "time":
                            let newResult = result as! ORKTimeOfDayQuestionResult
                            let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                            
                            if newResult.dateComponentsAnswer != nil {
                                let newAnswerAsFHIRTime = getFHIRTime(result: newResult)
                                newQuestionResponseAnswer.valueTime = newAnswerAsFHIRTime
                                
                                newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                                if newQuestionResponseAnswer.valueTime != nil && newQuestionResponse.answer != nil {
                                    newQuestionResponse.answer! += [newQuestionResponseAnswer]
                                }
                            }
                            
                        case "dateTime":
                            let newResult = result as! ORKDateQuestionResult
                            let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                            
                            if newResult.dateAnswer != nil {
                                let newAnswerAsFHIRDateTime = getFHIRDateTime(result: newResult, includeTime: true)
                                newQuestionResponseAnswer.valueDateTime = newAnswerAsFHIRDateTime
                                
                                newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                                if newQuestionResponseAnswer.valueDateTime != nil && newQuestionResponse.answer != nil {
                                    newQuestionResponse.answer! += [newQuestionResponseAnswer]
                                }
                            }
                            
                        case "date":
                            let newResult = result as! ORKDateQuestionResult
                            let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                            
                            if newResult.dateAnswer != nil {
                                let newAnswerAsFHIRDateTime = getFHIRDate(result: newResult)
                                newQuestionResponseAnswer.valueDate = newAnswerAsFHIRDateTime
                                
                                newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                                if newQuestionResponseAnswer.valueDate != nil && newQuestionResponse.answer != nil {
                                    newQuestionResponse.answer! += [newQuestionResponseAnswer]
                                }
                            }
                            
                        case "choice":
                            let newResult = result as! ORKChoiceQuestionResult
                            let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
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
                            
                        default:
                            print("something is wrong")
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
    
    func getFHIRDateTime(result: ORKDateQuestionResult, includeTime: Bool) -> DateTime {
        
        let resultDate = getFHIRDate(result: result)
        
        // set default time in case no time selected
        var resultTime = FHIRTime(hour: 0, minute: 0, second: 0)
        
        var resultTimeZone = TimeZone.current
        
        if includeTime {
           resultTime = getTimeFromDateTime(result: result)
            
            if result.timeZone != nil {
                resultTimeZone = result.timeZone!
            }
        }
        
        let resultDateTime = DateTime(date: resultDate, time: resultTime, timeZone: resultTimeZone)
        return resultDateTime
    }
    
    func getTimeFromDateTime(result: ORKDateQuestionResult) -> FHIRTime {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.hour], from: result.dateAnswer!)
        let resultHour = UInt8(exactly: components.hour ?? 0) ?? 0
        components = calendar.dateComponents([.minute], from: result.dateAnswer!)
        let resultMinute = UInt8(exactly: components.minute ?? 0) ?? 0
        components = calendar.dateComponents([.second], from: result.dateAnswer!)
        let resultSecond = Double(components.second ?? 0)
        return FHIRTime(hour: resultHour, minute: resultMinute, second: resultSecond)
        
    }
    
    func getFHIRDate(result: ORKDateQuestionResult) -> FHIRDate {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: result.dateAnswer!)
        let resultYear = components.year!
        
        components = calendar.dateComponents([.month], from: result.dateAnswer!)
        let resultMonth = UInt8(exactly: components.month!)
        components = calendar.dateComponents([.day], from: result.dateAnswer!)
        let resultDay = UInt8(exactly: components.day!)
        let resultDate = FHIRDate(year: resultYear, month: resultMonth, day: resultDay)
        
        return resultDate
    }
    
    func getFHIRTime(result: ORKTimeOfDayQuestionResult) -> FHIRTime {
        
        let answerHour = UInt8(exactly: result.dateComponentsAnswer?.hour ?? 0)!
        let answerMinute = UInt8(exactly: result.dateComponentsAnswer?.minute ?? 0)!
        let answerSecond = Double(result.dateComponentsAnswer?.second ?? 0)
        
        return FHIRTime(hour: answerHour, minute: answerMinute, second: answerSecond)
    }
    
}
