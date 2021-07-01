//
//  ConsentDocument.swift
//  sampleApp
//
//  Created by admin on 6/11/21.
//

import Foundation
import ResearchKit

public var ConsentDocument: ORKConsentDocument {
    let consentDocument = ORKConsentDocument()
    consentDocument.title = "Sample Consent"
    
    consentDocument.sections = consentSections

    // TODO: consent sections
    
    consentDocument.addSignature(ORKConsentSignature(forPersonWithTitle:nil, dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature"))
    
    
    
    return consentDocument
}

let consentSectionTypes: [ORKConsentSectionType] = [
    .overview,
    .dataGathering,
    .privacy,
    .dataUse,
    .timeCommitment,
    .studySurvey,
    .studyTasks,
    .withdrawing
]

var consentSections: [ORKConsentSection] = consentSectionTypes.map { contentSectionType
    in
    let consentSection = ORKConsentSection(type: contentSectionType)
    consentSection.summary = "If you wish to complete this study..."
    consentSection.content = "In this study you will be asked five questions."
    return consentSection
}

