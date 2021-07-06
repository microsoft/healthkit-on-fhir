//
//  ConfigHelper.swift
//  researchKitOnFhir
//
//  Created by admin on 7/5/21.
//

import Foundation

class ConfigHelper {
    static let smartClientBaseUrl = ProcessInfo.processInfo.environment[ "smartClientBaseUrl"]
    static let smartClientClientId = ProcessInfo.processInfo.environment["smartClientClientId"]
    static let redirect = ProcessInfo.processInfo.environment["redirect"]
}
