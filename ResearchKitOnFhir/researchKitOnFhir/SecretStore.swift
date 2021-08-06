//
//  SecretStore.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation

class SecretStore {
    public static func fetch(key: String) throws -> String? {
        var searchQuery = try query(key: key)
        searchQuery[kSecReturnData as String] = true
        
        if let valueData: Data = try search(query: searchQuery) {
            return String(data: valueData, encoding: .utf8)
        }
        
        return nil
    }
    
    public static func delete(key: String) throws {
        let status = SecItemDelete(try query(key: key) as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw SecretStoreError.deleteError(status: status)
        }
    }
    
    public static func save(key: String, value: String?) throws {
        guard value != nil else {
            try delete(key: key)
            return
        }
        
        guard let valueData = value!.data(using: .utf8) else {
            throw SecretStoreError.invalidSecretValue(value: value!)
        }
        
        var saveQuery = try query(key: key)
        saveQuery[kSecReturnAttributes as String] = true
        
        var status = errSecSuccess
        
        if let _: CFDictionary = try search(query: saveQuery) {
            saveQuery[kSecReturnAttributes as String] = nil
            status = SecItemUpdate(saveQuery as CFDictionary, [kSecValueData as String : valueData] as CFDictionary)
        } else {
            saveQuery[kSecReturnAttributes as String] = nil
            saveQuery[kSecValueData as String] = valueData
            status = SecItemAdd(saveQuery as CFDictionary, nil)
        }
        
        guard status == errSecSuccess else {
            throw SecretStoreError.saveError(status: status)
        }
    }
    
    private static func query(key: String) throws -> [String : Any] {
        guard let keyData = key.data(using: .utf8) else {
            throw SecretStoreError.invalidKeyValue(key: key)
        }
        
        var query = [String : Any]()
        query[kSecAttrService as String] = Bundle.main.bundleIdentifier
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrGeneric as String] = keyData
        query[kSecAttrAccount as String] = key
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        
        return query
    }
    
    private static func search<T>(query: [String : Any]) throws -> T? {
        var valueData: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &valueData)
        
        guard status != errSecItemNotFound else {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw SecretStoreError.fetchError(status: status)
        }
        
        guard let value = valueData as? T else {
            throw SecretStoreError.malformedSecretData
        }
        
        return value
    }
}
