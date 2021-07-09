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
                    print(locationResult)
                    let newQuestionResponseAnswer = QuestionnaireResponseItemAnswer()
                    let newAnswerAsFHIRRef = buildFHIRLocation(result: locationResult)
                    print (newAnswerAsFHIRRef)
                // newQuestionResponseAnswer.valueReference = newAnswerAsFHIRRef
                
                
                /* TODO: finish email - or exclude because it doesn't map well to FHIR?
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
    
    func FHIRQuestionListToRKQuestions (questions: [QuestionnaireItem], questionnaireTitle: String) -> [ORKStep] {
        var surveySteps = [ORKStep]()
        
        for question in questions {
            var answer = ORKAnswerFormat()
            switch(question.type?.rawValue){
            
            case "group":
                if question.linkId?.string == nil {
                    print("error position 1")
                }
                let stepForm = ORKFormStep(identifier: question.linkId!.string)
                var stepFormItems = [ORKFormItem]()
                
                if stepForm.formItems == nil {
                    stepForm.formItems = [ORKFormItem]()
                }
                if question.item != nil {
                    for item in question.item! {
                        if item.linkId?.string != nil {
                            let answerFormat = getAnswerFormat(question: item)
                            
                            
                            let newFormItem = ORKFormItem(identifier: item.linkId!.string, text: item.text?.string, answerFormat: getAnswerFormat(question: item))
                            stepFormItems += [newFormItem]
                            
                        } else {
                            print("error position 2")
                        }
                    }
                    stepForm.formItems! += stepFormItems
                    surveySteps += [stepForm]
                }
                
            case "text":
                answer = getAnswerFormat(question: question)
                let newQuestionStepContent = question.text?.string
                let newQuestionIdentifier = (question.linkId?.string)!
                let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
                surveySteps += [newStep]
                
            case "string":
                answer = getAnswerFormat(question: question)
                let newQuestionStepContent = question.text?.string
                let newQuestionIdentifier = (question.linkId?.string)!
                let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
                surveySteps += [newStep]
                
            case "integer":
                answer = getAnswerFormat(question: question)
                let newQuestionStepContent = question.text?.string
                let newQuestionIdentifier = (question.linkId?.string)!
                let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
                surveySteps += [newStep]
                
            case "boolean":
                answer = getAnswerFormat(question: question)
                let newQuestionStepContent = question.text?.string
                let newQuestionIdentifier = (question.linkId?.string)!
                let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
                surveySteps += [newStep]
                
            case "decimal":
                answer = getAnswerFormat(question: question)
                let newQuestionStepContent = question.text?.string
                let newQuestionIdentifier = (question.linkId?.string)!
                let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
                surveySteps += [newStep]
                
            case "time":
                answer = getAnswerFormat(question: question)
                let newQuestionStepContent = question.text?.string
                let newQuestionIdentifier = (question.linkId?.string)!
                let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
                surveySteps += [newStep]
                
            case "dateTime":
                answer = getAnswerFormat(question: question)
                let newQuestionStepContent = question.text?.string
                let newQuestionIdentifier = (question.linkId?.string)!
                let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
                surveySteps += [newStep]
                
            case "choice":
                answer = getAnswerFormat(question: question)
                let newQuestionStepContent = question.text?.string
                let newQuestionIdentifier = (question.linkId?.string)!
                let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
                surveySteps += [newStep]
                
            case "reference":
                answer = getAnswerFormat(question: question)
                let newQuestionStepContent = question.text?.string
                let newQuestionIdentifier = (question.linkId?.string)!
                let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
                surveySteps += [newStep]
                
            case "date":
                answer = getAnswerFormat(question: question)
                let newQuestionStepContent = question.text?.string
                let newQuestionIdentifier = (question.linkId?.string)!
                let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
                surveySteps += [newStep]
                
            case .none:
                print("none")
            case .some(_):
                print("CONVERSION some")
            }
        }
        return surveySteps
    }
    
    func getAnswerFormat(question: QuestionnaireItem) -> ORKAnswerFormat {
        var answer = ORKAnswerFormat()
        
        if question.type?.rawValue != nil {
            switch(question.type?.rawValue){
            
            case "text":
                if question.maxLength == nil {
                    answer = ORKTextAnswerFormat()
                } else {
                    answer = ORKTextAnswerFormat(maximumLength: question.maxLength!.int)
                }
                
            case "string":
                answer = ORKTextAnswerFormat()
            // TODO: multiple lines field not recognized because type seen by compiler as supertype
            
            /*
             if question.maxLength == nil {
             let answer = ORKTextAnswerFormat()
             answer.multipleLines = false
             } else {
             let answer = ORKTextAnswerFormat(maximumLength: question.maxLength!.int)
             answer.multipleLines = false
             }
             */
            
            case "integer":
                answer = ORKNumericAnswerFormat.integerAnswerFormat(withUnit: "")
            // TODO: add units somehow?
            
            case "boolean":
                answer = ORKBooleanAnswerFormat.booleanAnswerFormat()
                
            case "decimal":
                answer = ORKNumericAnswerFormat.decimalAnswerFormat(withUnit: "")
            // TODO: add units?
            
            case "time":
                answer = ORKTimeOfDayAnswerFormat()
                
            case "dateTime":
                answer = ORKDateAnswerFormat(style: ORKDateAnswerStyle.dateAndTime)
                
            case "date":
                answer = ORKDateAnswerFormat(style: ORKDateAnswerStyle.date)
                
            case "choice":
                let answerOptions = getTextChoiceFromFHIRType(question: question)
                answer = pickMultipleChoiceFormat(choices: answerOptions)
                
            case "reference":
                answer = ORKLocationAnswerFormat()
                
            case .none:
                print("answer format is none")
                
            case .some(_):
                print("answer format is some")
                print(question.type?.rawValue)
            }
        }
        
        return answer
    }
    
    func pickMultipleChoiceFormat(choices: [ORKTextChoice]) -> ORKAnswerFormat {
        var max = 0
        let maxThreshold = 10
        for choice in choices {
            if choice.text.count > max {
                max = choice.text.count
            }
        }
        var answerFormat = ORKAnswerFormat()
        if (max > maxThreshold) {
            // TODO: address single vs. multiple choice issue
            answerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: choices)
        } else {
            answerFormat = ORKValuePickerAnswerFormat(textChoices: choices)
        }
        return answerFormat
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
            self.buildQuestionMap(questionItems: questionnaire.item!)
            
            let steps = self.FHIRQuestionListToRKQuestions(questions: questionnaire.item!, questionnaireTitle: questionnaire.title?.string ?? "")
            
            QuestionnaireConverter.ORKStepQuestionnaire = steps
            
            completion(questionnaire.title?.string, steps, error)
        }
    }
    
    func buildQuestionMap (questionItems: [QuestionnaireItem]) {
        for questionItem in questionItems {
            
            if questionItem.type?.rawValue == "group" {
                buildQuestionMap(questionItems: questionItem.item!)
            } else {
                QuestionnaireConverter.FHIRQuestionMap[questionItem.linkId!.string] = questionItem
            }
        }
    }
}

