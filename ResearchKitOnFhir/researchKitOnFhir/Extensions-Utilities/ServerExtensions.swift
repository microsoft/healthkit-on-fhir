//
//  ServerExtensions.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation
import SMART

extension Server {
    
    public func fetchQuestionnaire(reference: String, task: Task, completion: @escaping (QuestionnaireType?, Error?) -> Void) {
        
        let query = removeQuestionnairePrefix(query: reference)
        
        Questionnaire.read(query, server: self) { questionnaireResult,error in
            guard error == nil else {
                completion(nil,error)
                return
            }
            
            if let questionnaire = questionnaireResult as? Questionnaire {
                // Questionnaire Resource exists
                completion(QuestionnaireType(task: task, questionnaire: questionnaire), nil)
            } else {
                // No Questionnaire Resource exists
                completion(nil, nil)
            }
        }
    }
    
    public func fetchTasks(completion: @escaping ([Task]?, Error?) -> Void) {
        
        var taskList = [Task]()
        
        Task.search(["owner" : ConfigHelper.patientId])
            .perform(self) { (bundle, error) in
                
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                
                if let bundleEntries = bundle?.entry {
                    
                    for taskBundleEntry in bundleEntries {
                        if let task = taskBundleEntry.resource as? Task {
                            taskList.append(task)
                        }
                    }
                    
                    completion(taskList, nil)
                    
                } else {
                    completion(nil, error)
                }
        }
    }
    
    func removeQuestionnairePrefix(query: String) -> String {
        let substringArray = query.split(separator: "/")
        return String(substringArray[1])
    }
}
