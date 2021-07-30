//
//  DateTimeResponseBuilder.swift
//  researchKitOnFhir
//

import Foundation
import FHIR
import ResearchKit

public class DateTimeResponseBuilder: FHIRResponseBuilder {
    
    public func convertResponse(type: String) -> QuestionnaireResponseItem {
        
        switch(type) {
        
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
            return newQuestionResponse
        
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
            
        default:
            print(type)
        }
        return newQuestionResponse
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
