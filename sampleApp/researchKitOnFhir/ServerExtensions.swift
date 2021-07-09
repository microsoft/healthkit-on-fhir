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
        
        Questionnaire.search(["identifier" : "genTest"])
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
}
