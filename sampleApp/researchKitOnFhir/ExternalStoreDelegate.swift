//
//  ExternalStoreDelegate.swift
//  researchKitOnFhir
//
//  Created by admin on 6/24/21.
//

import Foundation
import SMART
import UIKit

public class ExternalStoreDelegate {
    
    private let questionnaireMapSyncObject = NSObject()
    private let taskMapSyncObject = NSObject()
    
    public func getQuestionnairesFromServer (reference: String, task: Task, completion: @escaping (QuestionnaireType?, Error?) -> Void) {
        
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let smartClient = appDelegate?.smartClient
            
            smartClient?.server.fetchQuestionnaire(reference: reference, task: task) { (questionnaire, error) in
                // Ensure there is no error
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                
                guard let questionnaireId = questionnaire?.FHIRquestionnaire.id?.description else {
                    completion(nil, ExternalStoreDelegateError.noQuestionnairesInServer)
                    return
                }
                
                completion(questionnaire, error)
            }
        }
        
    }
    
    public func getTasksFromServer (completion: @escaping ([Task]?, Error?) -> Void) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let smartClient = appDelegate?.smartClient
        
        smartClient?.server.fetchTasks { (tasks, error) in
            // Ensure there is no error
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            if tasks == nil || tasks?.count == 0 {
                completion(nil, ExternalStoreDelegateError.noValidTaskInServer)
                return
            }
            
            completion(tasks, error)
        }
    }
}


