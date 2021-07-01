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

