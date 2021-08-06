//
//  FHIRResponseBuilder.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation
import FHIR
import ResearchKit

public class FHIRResponseBuilder {
    
    internal var resultLinkID: FHIRString
    internal var newQuestionResponse: QuestionnaireResponseItem
    internal var result: ORKResult
    
    init(result: ORKResult) {
        resultLinkID = FHIRString(result.identifier)
        newQuestionResponse = QuestionnaireResponseItem(linkId: resultLinkID)
        self.result = result
    }
    
}
