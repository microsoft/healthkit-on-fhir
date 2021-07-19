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
    
    public func getQuestionnairesFromServer (reference: String, completion: @escaping (QuestionnaireType?, Error?) -> Void) {
        
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let smartClient = appDelegate?.smartClient
            
            smartClient?.server.fetchQuestionnaire(reference: reference) { (questionnaire, error) in
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
    
    public func getTasksFromServer (completion: @escaping (String?, Error?) -> Void) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let smartClient = appDelegate?.smartClient
        
        smartClient?.server.fetchTasks { (task, error) in
            // Ensure there is no error
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let taskId = task?.id?.description else {
                completion(nil, ExternalStoreDelegateError.noValidTaskInServer)
                return
            }
            
            objc_sync_enter(self.questionnaireMapSyncObject)
            taskParser.singleTask = task!
            objc_sync_exit(self.questionnaireMapSyncObject)
            
            completion(task!.id?.string, error)
        }
    }
}


