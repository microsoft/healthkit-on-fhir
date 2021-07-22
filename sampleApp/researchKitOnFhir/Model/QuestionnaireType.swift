//
//  QuestionnaireType.swift
//  researchKitOnFhir
//
//  Created by admin on 7/18/21.
//

import Foundation
import ResearchKit
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
