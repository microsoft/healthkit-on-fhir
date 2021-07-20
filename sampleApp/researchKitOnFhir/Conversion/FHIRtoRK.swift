//
//  FHIRtoRK.swift
//  researchKitOnFhir
//
//  Created by admin on 7/13/21.
//

import Foundation
import SMART
import ResearchKit

public class FHIRtoRKConverter {
    
    static var FHIRQuestionnaire: Questionnaire = Questionnaire()
    static var FHIRQuestionMap: [String: QuestionnaireItem] = [:]
    static var currentIndex = Int()
    static var ORKStepQuestionnaire: [ORKStep] = [ORKStep]()
    
    init() {
        // do nothing
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
                        let itemLinkId = getQuestionId(question: item)
                        let newFormItem = ORKFormItem(identifier: itemLinkId, text: item.text?.string, answerFormat: getAnswerFormat(question: item))
                        stepFormItems += [newFormItem]
                    }
                    stepForm.formItems! += stepFormItems
                    surveySteps += [stepForm]
                }
                
            case "text":
                surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                
            case "string":
                surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                
            case "integer":
                surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                
            case "boolean":
                surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                
            case "decimal":
                surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                
            case "time":
                surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                
            case "dateTime":
                surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                
            case "choice":
                surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                
            case "reference":
                surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                
            case "date":
                surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                
            case .none:
                print("none")
            case .some(_):
                print("CONVERSION some")
            }
        }
        return surveySteps
    }
    
    func buildNewQuestion(question: QuestionnaireItem, questionnaireTitle: String) -> ORKQuestionStep {
        
        let answer = getAnswerFormat(question: question)
        let newQuestionStepContent = question.text?.string
        let newQuestionIdentifier = getQuestionId(question: question)
        
        let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
        
        return newStep
    }
    
    func getQuestionId (question: QuestionnaireItem) -> String {
        var newQuestionIdentifier = String()
        
        if question.linkId?.string != nil {
            newQuestionIdentifier = (question.linkId?.string)!
        } else {
            // TODO: let newQuestionIdentifier = assignLinkId(...)
        }
        
        return newQuestionIdentifier
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
                
                if answerOptions.count > 0 {
                    answer = pickMultipleChoiceFormat(choices: answerOptions)
                }
                
            case "reference":
                answer = ORKLocationAnswerFormat()
                
            case .none:
                answer = ORKTextAnswerFormat()
                
            case .some(_):
                print("answer format is some")
                // TODO: ask about better solution
                answer = ORKTextAnswerFormat()
            }
        } else {
            answer = ORKTextAnswerFormat()
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
        
        if question.answerOption != nil {
            for option in question.answerOption! {
                if option.valueString?.string != nil {
                    let textChoice = ORKTextChoice(text: option.valueString!.string, value: option.valueString!.string as NSString)
                    answerOptions.append(textChoice)
                }
            }
        }
        return answerOptions
    }
    
    func extractSteps (reference: String, complete: Bool, completion: @escaping (QuestionnaireType?, Bool?, Error?) -> Void) {
        let externalSD = ExternalStoreDelegate()
        
        externalSD.getQuestionnairesFromServer(reference: reference, complete: complete) { (questionnaire, error) in
            guard error == nil,
                  let questionnaire = questionnaire else {
                completion(nil, nil,error)
                return
            }
            
            if questionnaire.FHIRquestionnaire.item != nil {
                print("FHIR QUESTIONNAIRE ITEM: \(String(describing: questionnaire.FHIRquestionnaire.title?.description))")
                completion(questionnaire, nil, error)
            } else {
                completion(nil, nil, error)
            }
        }
    }
    
    func getORKStepsFromQuestionnaire(questionnaire: Questionnaire) -> [ORKStep] {
        
        var steps = [ORKStep]()
        
        if questionnaire.item != nil {
            
            self.buildQuestionMap(questionItems: questionnaire.item!)
            
            steps = self.FHIRQuestionListToRKQuestions(questions: questionnaire.item!, questionnaireTitle: questionnaire.title?.string ?? "")
        
        }
        
        return steps
        
    }
    
    func buildQuestionMap (questionItems: [QuestionnaireItem]) {
        for questionItem in questionItems {
            
            if questionItem.type?.rawValue == "group" {
                buildQuestionMap(questionItems: questionItem.item!)
            } else {
                FHIRtoRKConverter.FHIRQuestionMap[questionItem.linkId!.string] = questionItem
            }
        }
    }
}
