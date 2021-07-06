//
//  QuestionConverter.swift
//  researchKitOnFhir
//
//  Created by admin on 6/23/21.
//

import Foundation
import ResearchKit
import SMART

public class QuestionnaireConverter {
    
    static var FHIRQuestionnaire: Questionnaire = Questionnaire()
    static var FHIRQuestionMap: [String: QuestionnaireItem] = [:]
    static var ORKStepQuestionnaire: [ORKStep] = [ORKStep]()
    
    // var defaultEmptyQuestionnaireItemList: [QuestionnaireItem]
    
    init () {
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
                
                switch(QuestionnaireConverter.FHIRQuestionMap[result.identifier]?.type?.rawValue) {
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
                    let newAnswerAsFHIRDateTime = getFHIRDateTime(result: dateTimeResult)
                    newQuestionResponseAnswer.valueDateTime = newAnswerAsFHIRDateTime
                    
                    newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                    if newQuestionResponseAnswer.valueDateTime != nil && newQuestionResponse.answer != nil {
                        newQuestionResponse.answer! += [newQuestionResponseAnswer]
                    }
                    
                case "open-choice":
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
                    
                case "reference":
                    let locationResult = result as! ORKLocationQuestionResult
                    print(locationResult)
                    let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                    let newAnswerAsFHIRRef = buildFHIRLocation(result: locationResult)
                    
                    /* TODO: finish email
                    case "email":
                        let emailResult = result as! ORKTextQuestionResult
                        let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                        let newAnswerAsFHIREmail = FHIRString(emailResult.textAnswer!)
                        newQuestionResponseAnswer.valueString = newAnswerAsFHIREmail
                        
                        newQuestionResponse.answer = [QuestionnaireResponseItemAnswer]()
                        if newQuestionResponseAnswer.valueString != nil && newQuestionResponse.answer != nil {
                            newQuestionResponse.answer! += [newQuestionResponseAnswer]
                        }
                    */
                    
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
        FHIRLocation.position?.latitude = resultLocation?.region?.center.latitude
        FHIRLocation.position?.longitude = resultLocation?.region?.center.longitude
        // FHIRLocation.position?.longitude = resultLocation?.region?.identifier[1]
        
        return FHIRLocation
    }
    
    func getFHIRDateTime(result: ORKDateQuestionResult) -> DateTime {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: result.dateAnswer!)
        let resultYear = components.year!
        
        components = calendar.dateComponents([.month], from: result.dateAnswer!)
        let resultMonth = UInt8(exactly: components.month!)
        components = calendar.dateComponents([.day], from: result.dateAnswer!)
        let resultDay = UInt8(exactly: components.day!)
        let resultDate = FHIRDate(year: resultYear, month: resultMonth, day: resultDay)
        
        components = calendar.dateComponents([.hour], from: result.dateAnswer!)
        let resultHour = UInt8(exactly: components.hour ?? 0) ?? 0
        components = calendar.dateComponents([.minute], from: result.dateAnswer!)
        let resultMinute = UInt8(exactly: components.minute ?? 0) ?? 0
        components = calendar.dateComponents([.second], from: result.dateAnswer!)
        let resultSecond = Double(components.second ?? 0)
        let resultTime = FHIRTime(hour: resultHour, minute: resultMinute, second: resultSecond)
        
        let resultTimeZone = result.timeZone
 
        let resultDateTime = DateTime(date: resultDate, time: resultTime, timeZone: resultTimeZone)
        return resultDateTime
    }
    
    func getFHIRTime(result: ORKTimeOfDayQuestionResult) -> FHIRTime {
        let answerHour = UInt8(exactly: result.dateComponentsAnswer?.hour ?? 0)!
        let answerMinute = UInt8(exactly: result.dateComponentsAnswer?.minute ?? 0)!
        let answerSecond = Double(result.dateComponentsAnswer?.second ?? 0)
        
        return FHIRTime(hour: answerHour, minute: answerMinute, second: answerSecond)
    }
    
    func FHIRQuestionListToRKQuestions (questions: [QuestionnaireItem], questionnaireTitle: String) -> [ORKStep] {
        var surveySteps = [ORKStep]()
        var answer = ORKAnswerFormat()
        
        for question in questions {
            switch(question.type?.rawValue){
            case "string":
                answer = ORKTextAnswerFormat()
                
            case "integer":
                answer = ORKNumericAnswerFormat.integerAnswerFormat(withUnit: "years")
                // TODO: address units issue - no match in FHIR?
                
            case "boolean":
                answer = ORKBooleanAnswerFormat.booleanAnswerFormat()
                
            case "decimal":
                answer = ORKNumericAnswerFormat.decimalAnswerFormat(withUnit: "degrees celsius")
                // TODO: address units issue - no match in FHIR
            
            case "time":
                answer = ORKTimeOfDayAnswerFormat()
            
            case "dateTime":
                answer = ORKDateAnswerFormat(style: ORKDateAnswerStyle.dateAndTime)
                
            case "open-choice":
                let answerOptions = getTextChoiceFromFHIRType(question: question)
                answer = ORKValuePickerAnswerFormat(textChoices: answerOptions)
                
            case "reference":
                answer = ORKLocationAnswerFormat()
                
            /* TODO: finish email
            case "email":
                answer = ORKEmailAnswerFormat()
            */
                
            case .none:
                print("none")
            case .some(_):
                print("some")
            }
            
            let newQuestionStepContent = question.text?.string
            let newQuestionIdentifier = (question.linkId?.string)!
            let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
            surveySteps += [newStep]
        }
        return surveySteps
    }
    
    func getTextChoiceFromFHIRType (question: QuestionnaireItem) -> [ORKTextChoice] {
        var answerOptions = [ORKTextChoice]()
        for option in question.answerOption! {
            let textChoice = ORKTextChoice(text: option.valueString!.string, value: option.valueString!.string as NSString)
            answerOptions.append(textChoice)
        }
        return answerOptions
    }
    
    func extractSteps (completion: @escaping (String?, [ORKStep]?, Error?) -> Void) {
        let externalSD = ExternalStoreDelegate()
        
        externalSD.getQuestionnairesFromServer() { questionnaireId, error in
            guard error == nil,
                  let questionnaireId = questionnaireId else {
                completion(nil, nil,error)
                return
            }
            let questionnaire = QuestionnaireConverter.FHIRQuestionnaire
            QuestionnaireConverter.FHIRQuestionMap = self.buildQuestionMap(questionnaire: questionnaire)
            
            let steps = self.FHIRQuestionListToRKQuestions(questions: questionnaire.item!, questionnaireTitle: questionnaire.title!.string)
            
            QuestionnaireConverter.ORKStepQuestionnaire = steps
            
            completion(questionnaire.title?.string, steps, error)
        }
    }
    
    func buildQuestionMap (questionnaire: Questionnaire) -> [String: QuestionnaireItem]{
        var questions: [String: QuestionnaireItem] = [:]
        for questionItem in questionnaire.item! {
            questions[questionItem.linkId!.string] = questionItem
        }
        return questions
    }
}

