//
//  ServerExtensions.swift
//  researchKitOnFhir
//
//  Created by admin on 6/24/21.
//

import Foundation
import SMART

extension Server {
    
    public func fetchQuestionnaire(completion: @escaping (Questionnaire?, Error?) -> Void) {
        
        Questionnaire.search(taskParser.questionnaireIds)
            .perform(self) { (bundle, error) in
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                
                if let bundleEntry = bundle?.entry?.first,
                   let questionnaire = bundleEntry.resource as? Questionnaire {
                    // Complete with a Questionnaire Resource
                    print(questionnaire)
                    completion(questionnaire, nil)
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
                        taskParser.questionnaireIdList.append((task?.basedOn![0].reference!.string) ?? "")
                    }
                }
                
                print(taskParser.questionnaireIdList)
                
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
}
