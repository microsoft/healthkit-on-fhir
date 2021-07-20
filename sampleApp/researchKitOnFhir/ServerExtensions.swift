//
//  ServerExtensions.swift
//  researchKitOnFhir
//
//  Created by admin on 6/24/21.
//

import Foundation
import SMART

extension Server {
    
    public func fetchQuestionnaire(reference: String, completed: Bool, completion: @escaping (QuestionnaireType?, Error?) -> Void) {
        
        print("SEARCH: \(reference)")
        
        Questionnaire.search(["identifier": reference])
            .perform(self) { (bundle, error) in
                guard error == nil else {
                    completion(nil,error)
                    return
                }
                
                if let bundleEntries = bundle?.entry {
                    for bundleEntry in bundleEntries {
                        if let questionnaire = bundleEntry.resource as? Questionnaire {
                            print("QUESTIONNAIRE TITLE: \(questionnaire.title?.string)")
                            
                            completion(QuestionnaireType(questionnaire: questionnaire, complete: completed), nil)
                        } else {
                            // No Questionnaire Resource exists
                            completion(nil, nil)
                        }
                    }
                } else {
                    // No Questionnaire Resource exists
                    completion(nil,nil)
                }
            }
    }
    
    public func fetchTasks(completion: @escaping (Task?, Error?) -> Void) {
        
        Task.search(["owner" : samplePatient.id])
            .perform(self) { (bundle, error) in
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                
                if let bundleEntries = bundle?.entry {
                    for taskBundleEntry in bundleEntries {
                        let task = taskBundleEntry.resource as? Task
                        
                        var taskComplete: Bool
                        
                        if task?.status != nil || task?.status?.rawValue != nil {
                            if task?.status?.rawValue == "completed" {
                                taskComplete = true
                            } else {
                                taskComplete = false
                            }
                        } else {
                            taskComplete = false
                        }
                        taskParser.questionnaireIdList[(task?.basedOn![0].reference!.string)!] = taskComplete
                    }
                }
                
                print("QUESTIONNAIRE ID LIST: \(taskParser.questionnaireIdList)")
                
                
                if let bundleEntry = bundle?.entry?.first,
                   let task = bundleEntry.resource as? Task {
                    // Complete with a Questionnaire Resource
                    print("FETCH TASK: \(task)")
                    completion(task, nil)
                } else {
                    // No Questionnaire Resource exists
                    completion(nil,nil)
                }
                
        }
    }
    
    func removeQuestionnairePrefix(query: String) -> String {
        var substringArray = query.split(separator: "/")
        print(substringArray)
        return String(substringArray[1])
    }
}
