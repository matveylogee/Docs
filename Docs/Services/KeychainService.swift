//
//  KeychainService.swift
//  generator
//
//  Created by Матвей on 25.05.2025.
//

import Foundation
import Security

// MARK: - Ключи Keychain
enum KeychainKey: String {
    case authToken
}

// MARK: - Ошибка Keychain
enum KeychainError: Error {
    case unexpectedStatus(OSStatus)
}

protocol KeychainServiceProtocol {
    func save(_ value: String, for key: KeychainKey) throws
    func fetch(_ key: KeychainKey) throws -> String?
    func delete(_ key: KeychainKey) throws
}

final class KeychainService: KeychainServiceProtocol {
    
    // MARK: - Save
    func save(_ value: String, for key: KeychainKey) throws {
        let data = Data(value.utf8)
        let account = key.rawValue

        // 1) Удаляем старую запись (если есть)
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // 2) Добавляем новую
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Fetch
    func fetch(_ key: KeychainKey) throws -> String? {
        let account = key.rawValue
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
        guard let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Delete
    func delete(_ key: KeychainKey) throws {
        let account = key.rawValue
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
