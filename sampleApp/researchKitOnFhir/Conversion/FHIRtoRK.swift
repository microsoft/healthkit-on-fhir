//
//  FHIRtoRK.swift
//  researchKitOnFhir
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
            // ensures the question text is not empty
            if question.text != nil || question.type?.rawValue == "group" {
                
                switch(question.type?.rawValue){
                
                case "group":
                    let newFormStep = createGroupItem(question: question, title: questionnaireTitle)
                    if newFormStep.formItems != nil {
                        if newFormStep.formItems!.count > 0 {
                            surveySteps += [newFormStep]
                        }
                    }
                    
                case "text",
                     "string",
                     "integer",
                     "boolean",
                     "decimal",
                     "time",
                     "dateTime",
                     "choice",
                     "date":
                    surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                    
                case .none:
                    question.type = QuestionnaireItemType(rawValue: "text")
                    surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                    print("none")
                case .some(_):
                    question.type = QuestionnaireItemType(rawValue: "text")
                    surveySteps += [buildNewQuestion(question: question,  questionnaireTitle: questionnaireTitle)]
                    print("CONVERSION some")
                }
            }
        }
        return surveySteps
    }
    
    // converts FHIR "group" type to ORKFormStep with list of ORKFormItems
    func createGroupItem (question: QuestionnaireItem, title: String) -> ORKFormStep {
        let stepForm = ORKFormStep(identifier: question.linkId!.string)
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
            
            case "text":
                if question.maxLength == nil {
                    answer = ORKTextAnswerFormat()
                } else {
                    answer = ORKTextAnswerFormat(maximumLength: question.maxLength!.int)
                }
                
            case "string":
                answer = ORKTextAnswerFormat()
            
            case "integer":
                answer = ORKNumericAnswerFormat.integerAnswerFormat(withUnit: "")
            
            case "boolean":
                answer = ORKBooleanAnswerFormat.booleanAnswerFormat()
                
            case "decimal":
                answer = ORKNumericAnswerFormat.decimalAnswerFormat(withUnit: "")
            
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
