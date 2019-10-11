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
    public static var smartClientAuthorizeUri = ""
    public static var smartClientTokenUri = ""
    
    private static let configPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("SavedConfiguration.json")
    
    public static func loadSavedConfiguration() -> Bool
    {
        return loadConfiguation(url: configPath)
    }
    
    public static func loadConfiguation(url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : String] {
                
                if set(variable: &eventHubsConnectionString, value: dictionary["eventHubsConnectionString"]) &&
                set(variable: &smartClientBaseUrl, value: dictionary["smartClientBaseUrl"]) &&
                set(variable: &smartClientClientId, value: dictionary["smartClientClientId"]) &&
                set(variable: &smartClientAuthorizeUri, value: dictionary["smartClientAuthorizeUri"]) &&
                    set(variable: &smartClientTokenUri, value: dictionary["smartClientTokenUri"]) {
                    saveCurrentConfiguration(data: data)
                    return true
                }
            }
        } catch {
            print("Error loading config file - \(error)")
            return false
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
    
    private static func saveCurrentConfiguration(data: Data) {
        do {
            try data.write(to: configPath)
        } catch {
            print("Error saving config file - \(error)")
        }
    }
}
