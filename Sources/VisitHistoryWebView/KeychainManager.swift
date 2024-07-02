import Foundation
import Security

public class KeychainManager {
    public static let shared = KeychainManager()
    private let keysArrayKey = "com.yourcompany.keychainKeys"

    private init() {
        initializeKeychainKeys()
    }

    private func initializeKeychainKeys() {
        if UserDefaults.standard.array(forKey: keysArrayKey) == nil {
            UserDefaults.standard.set([String](), forKey: keysArrayKey)
        }
    }

    private func addKeychainKey(_ key: String) {
        var keys = UserDefaults.standard.stringArray(forKey: keysArrayKey) ?? []
        if !keys.contains(key) {
            keys.append(key)
            UserDefaults.standard.set(keys, forKey: keysArrayKey)
        }
    }

    private func removeKeychainKey(_ key: String) {
        var keys = UserDefaults.standard.stringArray(forKey: keysArrayKey) ?? []
        if let index = keys.firstIndex(of: key) {
            keys.remove(at: index)
            UserDefaults.standard.set(keys, forKey: keysArrayKey)
        }
    }

    public func getAllKeys() -> [String] {
        return UserDefaults.standard.stringArray(forKey: keysArrayKey) ?? []
    }

    public func save(key: String, value: String) -> Bool {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            addKeychainKey(key)
            return true
        }
        return false
    }

    public func retrieve(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue as Any
        ]
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let data = item as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    public func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            removeKeychainKey(key)
            return true
        }
        return false
    }
}
