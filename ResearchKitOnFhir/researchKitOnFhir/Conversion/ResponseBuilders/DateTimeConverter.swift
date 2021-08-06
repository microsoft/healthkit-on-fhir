//
//  DateTimeConverter.swift
//  researchKitOnFhir
//

import Foundation
import FHIR
import ResearchKit

public class DateTimeConverter {
    
    func getFHIRDate(result: ORKDateQuestionResult) -> FHIRDate {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: result.dateAnswer!)
        let resultYear = components.year!
        
        components = calendar.dateComponents([.month], from: result.dateAnswer!)
        let resultMonth = UInt8(exactly: components.month!)
        components = calendar.dateComponents([.day], from: result.dateAnswer!)
        let resultDay = UInt8(exactly: components.day!)
        let resultDate = FHIRDate(year: resultYear, month: resultMonth, day: resultDay)
        
        return resultDate
    }
    
}
