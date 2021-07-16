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
        
        for stepResults in taskResult! as! [ORKStepResult]
        {
            for result in stepResults.results!
            {
                let resultLinkID = FHIRString(result.identifier)
                let newQuestionResponse = QuestionnaireResponseItem(linkId: resultLinkID)
                
                switch(FHIRtoRKConverter.FHIRQuestionMap[result.identifier]?.type?.rawValue) {
                
                case "text":
                    let stringResult = result as! ORKTextQuestionResult
                    let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                    let newAnswerAsFHIRString = FHIRString(stringResult.textAnswer!)
                    newQuestionResponseAnswer.valueString = newAnswerAsFHIRString
                    
                    newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                    if newQuestionResponseAnswer.valueString != nil && newQuestionResponse.answer != nil {
                        newQuestionResponse.answer! += [newQuestionResponseAnswer]
                    }
                    
                case "string":
                    let stringResult = result as! ORKTextQuestionResult
                    let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                    let newAnswerAsFHIRString = FHIRString(stringResult.textAnswer!)
                    newQuestionResponseAnswer.valueString = newAnswerAsFHIRString
                    
                    newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                    if newQuestionResponseAnswer.valueString != nil && newQuestionResponse.answer != nil {
                        newQuestionResponse.answer! += [newQuestionResponseAnswer]
                    }
                    
                case "integer":
                    let integerResult = result as! ORKNumericQuestionResult
                    let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                    let newAnswerAsFHIRInteger = FHIRInteger(integerResult.numericAnswer as! Int32)
                    newQuestionResponseAnswer.valueInteger = newAnswerAsFHIRInteger
                    
                    newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                    if newQuestionResponseAnswer.valueInteger != nil && newQuestionResponse.answer != nil {
                        newQuestionResponse.answer! += [newQuestionResponseAnswer]
                    }
                    
                case "boolean":
                    let booleanResult = result as! ORKBooleanQuestionResult
                    let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                    let newAnswerAsFHIRBoolean = FHIRBool(booleanLiteral: (booleanResult.booleanAnswer != nil))
                    newQuestionResponseAnswer.valueBoolean = newAnswerAsFHIRBoolean
                    
                    newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                    if newQuestionResponseAnswer.valueBoolean != nil && newQuestionResponse.answer != nil {
                        newQuestionResponse.answer! += [newQuestionResponseAnswer]
                    }
                    
                case "decimal":
                    let decimalResult = result as! ORKNumericQuestionResult
                    let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                    let newAnswerAsFHIRDecimal = FHIRDecimal(decimalResult.numericAnswer as! Decimal)
                    newQuestionResponseAnswer.valueDecimal = newAnswerAsFHIRDecimal
                    
                    newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                    if newQuestionResponseAnswer.valueDecimal != nil && newQuestionResponse.answer != nil {
                        newQuestionResponse.answer! += [newQuestionResponseAnswer]
                    }
                    
                case "time":
                    let timeOfDayResult = result as! ORKTimeOfDayQuestionResult
                    let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                    let newAnswerAsFHIRTime = getFHIRTime(result: timeOfDayResult)
                    newQuestionResponseAnswer.valueTime = newAnswerAsFHIRTime
                    
                    newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                    if newQuestionResponseAnswer.valueTime != nil && newQuestionResponse.answer != nil {
                        newQuestionResponse.answer! += [newQuestionResponseAnswer]
                    }
                    
                case "dateTime":
                    let dateTimeResult = result as! ORKDateQuestionResult
                    let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                    let newAnswerAsFHIRDateTime = getFHIRDateTime(result: dateTimeResult, includeTime: true)
                    newQuestionResponseAnswer.valueDateTime = newAnswerAsFHIRDateTime
                    
                    newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                    if newQuestionResponseAnswer.valueDateTime != nil && newQuestionResponse.answer != nil {
                        newQuestionResponse.answer! += [newQuestionResponseAnswer]
                    }
                    
                case "date":
                    let dateResult = result as! ORKDateQuestionResult
                    let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                    let newAnswerAsFHIRDateTime = getFHIRDate(result: dateResult)
                    newQuestionResponseAnswer.valueDate = newAnswerAsFHIRDateTime
                    
                    newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                    if newQuestionResponseAnswer.valueDate != nil && newQuestionResponse.answer != nil {
                        newQuestionResponse.answer! += [newQuestionResponseAnswer]
                    }
                    
                    
                case "choice":
                    let openChoiceResult = result as! ORKChoiceQuestionResult
                    let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                    let answerArray = openChoiceResult.answer as! NSArray
                    
                    var newAnswerAsFHIRString = FHIRString("no response")
                    
                    // TODO: better error handling
                    if answerArray.count > 0 {
                        newAnswerAsFHIRString.string = answerArray[0] as! String
                    }
                    
                    newQuestionResponseAnswer.valueString = newAnswerAsFHIRString
                    
                    newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                    if newQuestionResponseAnswer.valueString != nil && newQuestionResponse.answer != nil {
                        newQuestionResponse.answer! += [newQuestionResponseAnswer]
                    }
                    
                // TODO: finish location - or exclude because it doesn't map well to FHIR?
                case "reference":
                    let locationResult = result as! ORKLocationQuestionResult
                    // print(locationResult)
                    let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                    let newAnswerAsFHIRRef = buildFHIRLocation(result: locationResult)
                    print (newAnswerAsFHIRRef)
                // newQuestionResponseAnswer.valueReference = newAnswerAsFHIRRef
                
                default:
                    print("something is wrong")
                }
                FHIRQuestionResponses += [newQuestionResponse]
            }
        }
        questionnaireResponse.item = FHIRQuestionResponses
        questionnaireResponse.status = QuestionnaireResponseStatus.completed
        return questionnaireResponse
    }
    
    func buildFHIRLocation(result: ORKLocationQuestionResult) -> Location {
        let FHIRLocation = Location()
        let resultLocation = result.locationAnswer
        let resultAddress = Address()
        
        resultAddress.line = resultLocation?.addressDictionary!["FormattedAddressLines"] as? [FHIRString]
        resultAddress.city = resultLocation?.addressDictionary!["City"] as? FHIRString
        resultAddress.district = resultLocation?.addressDictionary!["SubAdministrativeArea"] as? FHIRString
        resultAddress.country = resultLocation?.addressDictionary!["Country"] as? FHIRString
        resultAddress.postalCode = resultLocation?.addressDictionary!["ZIP"] as? FHIRString
        resultAddress.state = resultLocation?.addressDictionary!["State"] as? FHIRString
        
        FHIRLocation.address = resultAddress
        FHIRLocation.name?.string = (resultLocation?.userInput)!
        
        let newLatitude = FHIRDecimal(Decimal((resultLocation?.region!.center.latitude)!))
        let newLongitude = FHIRDecimal(Decimal((resultLocation?.region!.center.longitude)!))
        FHIRLocation.position? = LocationPosition(latitude: newLatitude, longitude: newLongitude)
        
        return FHIRLocation
    }
    
    func getFHIRDateTime(result: ORKDateQuestionResult, includeTime: Bool) -> DateTime {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: result.dateAnswer!)
        let resultYear = components.year!
        
        components = calendar.dateComponents([.month], from: result.dateAnswer!)
        let resultMonth = UInt8(exactly: components.month!)
        components = calendar.dateComponents([.day], from: result.dateAnswer!)
        let resultDay = UInt8(exactly: components.day!)
        let resultDate = FHIRDate(year: resultYear, month: resultMonth, day: resultDay)
        
        var resultTime = FHIRTime(hour: 0, minute: 0, second: 0)
        var resultTimeZone = TimeZone.current
        
        if includeTime {
            components = calendar.dateComponents([.hour], from: result.dateAnswer!)
            let resultHour = UInt8(exactly: components.hour ?? 0) ?? 0
            components = calendar.dateComponents([.minute], from: result.dateAnswer!)
            let resultMinute = UInt8(exactly: components.minute ?? 0) ?? 0
            components = calendar.dateComponents([.second], from: result.dateAnswer!)
            let resultSecond = Double(components.second ?? 0)
            resultTime = FHIRTime(hour: resultHour, minute: resultMinute, second: resultSecond)
            
            if result.timeZone != nil {
                resultTimeZone = result.timeZone!
            }
        }
        
        let resultDateTime = DateTime(date: resultDate, time: resultTime, timeZone: resultTimeZone)
        return resultDateTime
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
