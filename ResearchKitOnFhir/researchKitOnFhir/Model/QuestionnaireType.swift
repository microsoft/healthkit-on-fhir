//
//  QuestionnaireType.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation
import SMART

public class QuestionnaireType {
    
    var FHIRquestionnaire: Questionnaire
    var FHIRtask: Task
    var tagNum: Int
    
    init(task: Task, questionnaire: Questionnaire) {
        FHIRquestionnaire = questionnaire
        FHIRtask = task
        tagNum = -1
    }
}
