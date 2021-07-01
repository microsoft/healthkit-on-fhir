//
//  SurveyTask.swift
//  researchKitOnFhir
//
//  Created by admin on 6/11/21.
//

import Foundation
import ResearchKit
import FHIR

public var SurveyTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    
    let converter = QuestionnaireConverter()
    let externalSD = ExternalStoreDelegate()
    
    converter.extractSteps { (qTitle, steps, error) in
        
    }

  /*
    let instructionStep = ORKInstructionStep(identifier: "IntroStep")
    instructionStep.title = "Starter Survey"
    instructionStep.text = "Please answer the following questions."
    steps += [instructionStep]
    
    let groupName = "Sample Questionnaire"
    
    // build the question and turn it into a FHIR QuestionnaireItem
    
    // NAME QUESTION
    let nameAnswerFormat = ORKTextAnswerFormat(maximumLength: 20)
    nameAnswerFormat.multipleLines = false
    
    let nameQuestionStepTitle = "What is your name?"
    var questionIdentifier = "0"
    let nameQuestionStep = ORKQuestionStep(identifier: questionIdentifier, title: groupName, question: nameQuestionStepTitle, answer: nameAnswerFormat)
    
    steps += [nameQuestionStep]
    
    // FHIRQuestionList += RKtoFHIR(nameQuestionStep, questionIdentifier)
    
    // AGE QUESTION
    let ageQuestion = "How old are you?"
    questionIdentifier = "1"
    let ageAnswer = ORKNumericAnswerFormat.integerAnswerFormat(withUnit: "years")
    ageAnswer.minimum = 18
    ageAnswer.maximum = 85
    let ageQuestionStep = ORKQuestionStep(identifier: questionIdentifier, title: groupName, question: ageQuestion, answer: ageAnswer)
    steps += [ageQuestionStep]
    // RKtoFHIR(nameQuestionStep,  "1")
    
    // FHIRQuestionList += RKtoFHIR(nameQuestionStep, questionIdentifier)
    
    //TODO: add summary step
  */
  return ORKOrderedTask(identifier: "obsolete", steps: steps)
}
