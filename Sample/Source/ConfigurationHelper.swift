//
//  ConfigurationHelper.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class ConfigurationHelper {
    public static var eventHubsConnectionString = ""
    public static var smartClientBaseUrl = ""
    public static var smartClientClientId = ""
    
    public static func loadSavedConfiguration() -> Bool {
        return fetchStoredConfig()
    }
    
    public static func loadConfiguation(url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : String] {
                try SecretStore.save(key: "eventHubsConnectionString", value: dictionary["eventHubsConnectionString"])
                try SecretStore.save(key: "smartClientBaseUrl", value: dictionary["smartClientBaseUrl"])
                try SecretStore.save(key: "smartClientClientId", value: dictionary["smartClientClientId"])
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
            if set(variable: &eventHubsConnectionString, value: try SecretStore.fetch(key: "eventHubsConnectionString")),
                set(variable: &smartClientBaseUrl, value: try SecretStore.fetch(key: "smartClientBaseUrl")),
                set(variable: &smartClientClientId, value: try SecretStore.fetch(key: "smartClientClientId")) {
                return true
            }
        } catch {
            print("Error loading stored config values - \(error)")
        }
        
        return false
    }
}
