//
//  SettingViewController.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation
import AppKit
import Security

final class SettingViewController: NSViewController {
    
    @IBOutlet weak var apikeyField: NSSecureTextField!
    
    @IBAction func saveAction(_ sender: Any) {
        let key = apikeyField.stringValue
        
        let keyData = key.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "typetrack",
            kSecValueData as String: keyData
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func loadApiKeyFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "typetrack",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }

        return key
    }
}
