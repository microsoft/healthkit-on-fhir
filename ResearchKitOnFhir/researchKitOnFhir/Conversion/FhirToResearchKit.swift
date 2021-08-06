//
//  FhirToResearchKit.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation
import SMART
import ResearchKit

public class FhirToResearchKitConverter {
    
    static var fhirQuestionnaire: Questionnaire = Questionnaire()
    static var fhirQuestionMap: [String: QuestionnaireItem] = [:]
    static var currentIndex = Int()
    
    func fhirQuestionListToResearchKitQuestions (questions: [QuestionnaireItem], questionnaireTitle: String) -> [ORKStep] {
        var surveySteps = [ORKStep]()
        
        for question in questions {
            // ensures the question text is not empty
            if question.text != nil || question.type?.rawValue == fhirTypes.group {
                
                switch(question.type?.rawValue){
                
                case fhirTypes.group:
                    if let newFormStep = createGroupItem(question: question, title: questionnaireTitle){
                        if let formItems = newFormStep.formItems {
                            if formItems.count > 0 {
                                surveySteps += [newFormStep]
                            }
                        }
                    }
                    
                case fhirTypes.text,
                     fhirTypes.string,
                     fhirTypes.integer,
                     fhirTypes.boolean,
                     fhirTypes.decimal,
                     fhirTypes.time,
                     fhirTypes.dateTime,
                     fhirTypes.choice,
                     fhirTypes.date:
                    surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                    
                case .none:
                    question.type = QuestionnaireItemType(rawValue: fhirTypes.text)
                    surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                    print("none")
                case .some(_):
                    question.type = QuestionnaireItemType(rawValue: fhirTypes.text)
                    surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                    print("CONVERSION some")
                }
            }
        }
        return surveySteps
    }
    
    // converts FHIR "group" type to ORKFormStep with list of ORKFormItems
    func createGroupItem (question: QuestionnaireItem, title: String) -> ORKFormStep? {
        
        var stepForm: ORKFormStep
        
        if let linkId = question.linkId {
            stepForm = ORKFormStep(identifier: linkId.string)
        } else  {
            return nil
        }
        
        stepForm.title = title
        var stepFormItems = [ORKFormItem]()
        
        if stepForm.formItems == nil {
            stepForm.formItems = [ORKFormItem]()
        }
        if question.item != nil {
            for item in question.item! {
                
                // linkId has 1-1 cardinality per FHIR spec
                let itemLinkId = (item.linkId?.string)!
                let newFormItem = ORKFormItem(identifier: itemLinkId, text: item.text?.string, answerFormat: getAnswerFormat(question: item))
                stepFormItems += [newFormItem]
            }
            stepForm.formItems! += stepFormItems
        }
        return stepForm
    }
    
    func buildNewQuestion(question: QuestionnaireItem, questionnaireTitle: String) -> ORKQuestionStep {
        
        let answer = getAnswerFormat(question: question)
        let newQuestionStepContent = question.text?.string
        
        // linkId has 1-1 cardinality per FHIR spec
        let newQuestionIdentifier = (question.linkId?.string)!
        
        let newStep = ORKQuestionStep(identifier: newQuestionIdentifier, title: questionnaireTitle, question: newQuestionStepContent, answer: answer)
        
        return newStep
    }
    
    func getAnswerFormat(question: QuestionnaireItem) -> ORKAnswerFormat {
        var answer = ORKAnswerFormat()
        
        if question.type?.rawValue != nil {
            switch(question.type?.rawValue){
            
            case fhirTypes.text:
                if question.maxLength == nil {
                    answer = ORKTextAnswerFormat()
                } else {
                    answer = ORKTextAnswerFormat(maximumLength: question.maxLength!.int)
                }
                
            case fhirTypes.string:
                answer = ORKTextAnswerFormat()
            
            case fhirTypes.integer:
                answer = ORKNumericAnswerFormat.integerAnswerFormat(withUnit: "")
            
            case fhirTypes.boolean:
                answer = ORKBooleanAnswerFormat.booleanAnswerFormat()
                
            case fhirTypes.decimal:
                answer = ORKNumericAnswerFormat.decimalAnswerFormat(withUnit: "")
            
            case fhirTypes.time:
                answer = ORKTimeOfDayAnswerFormat()
                
            case fhirTypes.dateTime:
                answer = ORKDateAnswerFormat(style: ORKDateAnswerStyle.dateAndTime)
                
            case fhirTypes.date:
                answer = ORKDateAnswerFormat(style: ORKDateAnswerStyle.date)
                
            case fhirTypes.choice:
                let answerOptions = getTextChoiceFromFHIRType(question: question)
                
                if answerOptions.count > 0 {
                    answer = pickMultipleChoiceFormat(choices: answerOptions)
                }
                
            case .none:
                answer = ORKTextAnswerFormat()
                
            case .some(_):
                answer = ORKTextAnswerFormat()
            }
        } else {
            answer = ORKTextAnswerFormat()
        }
        
        return answer
    }
    
    func pickMultipleChoiceFormat(choices: [ORKTextChoice]) -> ORKAnswerFormat {
        var max = 0
        
        // somewhat arbitrary threshold to choose Value Picker vs. Multiple Choice UI
        let maxThreshold = 10
        for choice in choices {
            if choice.text.count > max {
                max = choice.text.count
            }
        }
        var answerFormat = ORKAnswerFormat()
        
        if (max > maxThreshold) {
            // TODO: currently only supports single choice (FHIR does not provide field for choosing multiple answers)
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
    
    func extractSteps (reference: String, task: Task, completion: @escaping (QuestionnaireType?, Error?) -> Void) {
        let externalSD = ExternalStoreDelegate()
        
        externalSD.getQuestionnairesFromServer(reference: reference, task: task) { (questionnaire, error) in
            guard error == nil,
                  let questionnaire = questionnaire else {
                completion(nil, error)
                return
            }
            
            if questionnaire.FHIRquestionnaire.item != nil {
                completion(questionnaire, error)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getORKStepsFromQuestionnaire(questionnaire: Questionnaire) -> [ORKStep] {
        
        var steps = [ORKStep]()
        
        if questionnaire.item != nil {
            
            self.buildQuestionMap(questionItems: questionnaire.item!)
            
            steps = self.fhirQuestionListToResearchKitQuestions(questions: questionnaire.item!, questionnaireTitle: questionnaire.title?.string ?? "")
        
        }
        
        return steps
        
    }
    
    func buildQuestionMap (questionItems: [QuestionnaireItem]) {
        for questionItem in questionItems {
            
            if questionItem.type?.rawValue == fhirTypes.group {
                buildQuestionMap(questionItems: questionItem.item!)
            } else {
                FhirToResearchKitConverter.fhirQuestionMap[questionItem.linkId!.string] = questionItem
            }
        }
    }
}
