//
//  ConfigHelper.swift
//  researchKitOnFhir
//
//  Created by admin on 7/5/21.
//

import Foundation

class ConfigHelper {
    // TODO: set all to "" - to be loaded in loadConfiguration
    
    // static let testerSmartClientBaseUrl = ProcessInfo.processInfo.environment[ "smartClientBaseUrl"]
    // static let testerSmartClientClientId = ProcessInfo.processInfo.environment["smartClientClientId"]
    // static let testerRedirect = ProcessInfo.processInfo.environment["redirect"]
    
    static var smartClientBaseUrl = ""
    static var smartClientClientId = ""
    static var appRedirect = ""
    static var patientId = "" 
    
    public static func loadSavedConfiguration() -> Bool {
        return fetchStoredConfig()
    }
    
    public static func loadConfiguration(url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : String] {
                try SecretStore.save(key: "smartClientBaseUrl", value: dictionary["smartClientBaseUrl"])
                try SecretStore.save(key: "smartClientClientId", value: dictionary["smartClientClientId"])
                try SecretStore.save(key: "appRedirect", value: dictionary["appRedirect"])
                try SecretStore.save(key: "patientId", value: dictionary["patientId"])
                return fetchStoredConfig()
            }
        } catch {
            print("Error loading config file - \(error)")
        }
        
        return false
    }
    
    private static func set(variable: inout String, value: String?) -> Bool {
        guard value != nil else {
            return false
        }
        
        variable = value!
        return true
    }
    
    private static func fetchStoredConfig() -> Bool {
        do {
            if set(variable: &smartClientBaseUrl, value: try SecretStore.fetch(key: "smartClientBaseUrl")),
                set(variable: &smartClientClientId, value: try SecretStore.fetch(key: "smartClientClientId")),
                set(variable: &appRedirect, value: try SecretStore.fetch(key: "appRedirect")),
                set(variable: &patientId, value: try SecretStore.fetch(key: "patientId")) {
                return true
            }
        } catch {
            print("Error loading stored config values - \(error)")
        }
        
        return false
    }
    
}
