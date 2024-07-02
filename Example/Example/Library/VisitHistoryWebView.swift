import UIKit
import WebKit

// 사용자 정의 에러 타입
public enum HistoryManagerError: Error {
    case urlAlreadyExists
    case invalidIndex
}

// 저장소 타입을 결정하는 열거형
public enum StorageType {
    case userDefaults // UserDefaults
    case inMemory // 메모리 내 저장
    case keychain // Keychain
}

open class HistoryManager {
    public static let shared = HistoryManager()
    private var storageType: StorageType = .inMemory
    public var historyList = [URL: Int]()
    
    private let historyKey = "HistoryManagerKey"
    
    private init() {}
    
    // 저장소 타입 설정 함수
    open func configureStorageType(_ type: StorageType) {
        storageType = type
        switch storageType {
        case .userDefaults:
            loadHistoryFromUserDefaults()
        case .keychain:
            loadHistoryFromKeychain()
        case .inMemory:
            break
        }
    }
    
    // URL 히스토리 추가 함수
    open func addHistory(_ url: URL, shouldPrint: Bool = true) throws {
        switch storageType {
        case .inMemory:
            try addHistoryToMemory(url, shouldPrint: shouldPrint)
        case .userDefaults:
            try addHistoryToUserDefaults(url, shouldPrint: shouldPrint)
        case .keychain:
            try addHistoryToKeychain(url, shouldPrint: shouldPrint)
        }
    }
    
    // 저장된 URL 히스토리를 가져오는 함수
    open func getHistory() -> [URL] {
        switch storageType {
        case .inMemory:
            return Array(historyList.keys)
        case .userDefaults:
            let history = getHistoryFromUserDefaults()
            return history.keys.sorted { $0.absoluteString < $1.absoluteString }
        case .keychain:
            return Array(getHistoryFromKeychain().keys)
        }
    }
    
    // 지정된 인덱스의 URL 히스토리를 삭제하는 함수
    open func deleteHistory(at index: Int, shouldPrint: Bool = true) throws {
        switch storageType {
        case .inMemory:
            try deleteHistoryFromMemory(at: index, shouldPrint: shouldPrint)
        case .userDefaults:
            try deleteHistoryFromUserDefaults(at: index, shouldPrint: shouldPrint)
        case .keychain:
            try deleteHistoryFromKeychain(at: index, shouldPrint: shouldPrint)
        }
    }
    
    // 모든 URL 히스토리를 삭제하는 함수
    open func clearHistory(shouldPrint: Bool = true) {
        switch storageType {
        case .inMemory:
            historyList.removeAll()
        case .userDefaults:
            UserDefaults.standard.removeObject(forKey: historyKey)
        case .keychain:
            clearHistoryFromKeychain()
        }
        if shouldPrint {
            print("All history cleared")
        }
    }
    
    // 지정된 인덱스의 URL을 새 URL로 업데이트하는 함수
    open func updateHistory(at index: Int, with newUrl: URL, shouldPrint: Bool = true) throws {
        switch storageType {
        case .inMemory:
            try updateHistoryInMemory(at: index, with: newUrl, shouldPrint: shouldPrint)
        case .userDefaults:
            try updateHistoryInUserDefaults(at: index, with: newUrl, shouldPrint: shouldPrint)
        case .keychain:
            try updateHistoryInKeychain(at: index, with: newUrl, shouldPrint: shouldPrint)
        }
    }
    
    open func searchHistory(keyword: String) -> [URL] {
        let filteredHistory = getHistory().filter { $0.absoluteString.contains(keyword) }
        return filteredHistory
    }
    
    open func getRecentHistory(limit: Int) -> [URL] {
        let sortedHistory = historyList.sorted { $0.value > $1.value }
        return Array(sortedHistory.prefix(limit).map { $0.key })
    }
}

// 메모리 저장 코드
private extension HistoryManager {
    // 메모리에 URL 히스토리를 추가하는 내부 함수
    func addHistoryToMemory(_ url: URL, shouldPrint: Bool) throws {
        if let count = historyList[url] {
            historyList[url] = count + 1
            if shouldPrint {
                print("array -> URL Added to History: \(url.absoluteString), Number of visits: \(count + 1)")
            }
        } else {
            historyList[url] = 1
            if shouldPrint {
                print("array -> URL Added to History: \(url.absoluteString)")
            }
        }
    }
    
    // 메모리에서 지정된 인덱스의 URL을 새 URL로 업데이트하는 내부 함수
    private func updateHistoryInMemory(at index: Int, with newUrl: URL, shouldPrint: Bool) throws {
        guard index >= 0 && index < historyList.count else {
            throw HistoryManagerError.invalidIndex
        }
        let key = Array(historyList.keys)[index]
        let visitCount = historyList.removeValue(forKey: key)
        historyList[newUrl] = visitCount
        if shouldPrint {
            print("URL Updated from \(key.absoluteString) to \(newUrl.absoluteString)")
        }
    }
    
    // 메모리에서 지정된 인덱스의 URL 히스토리를 삭제하는 내부 함수
    private func deleteHistoryFromMemory(at index: Int, shouldPrint: Bool) throws {
        guard index >= 0 && index < historyList.count else {
            throw HistoryManagerError.invalidIndex
        }
        let key = Array(historyList.keys)[index]
        historyList.removeValue(forKey: key)
        if shouldPrint {
            print("URL Deleted from History at index: \(index)")
        }
    }
}

// UserDefaults 저장 코드
private extension HistoryManager {
    
    // UserDefaults에 URL 히스토리를 추가하는 내부 함수
    func addHistoryToUserDefaults(_ url: URL, shouldPrint: Bool) throws {
        var history = getHistoryFromUserDefaults()
        let visitCount = (history[url] ?? 0) + 1
        history[url] = visitCount
        UserDefaults.standard.set(history.map { [$0.key.absoluteString: $0.value] }, forKey: historyKey)
        if shouldPrint {
            print("userDefaults -> URL \(visitCount == 1 ? "Added to" : "Updated in") History: \(url.absoluteString)")
        }
    }
    
    // UserDefaults에서 URL 히스토리를 불러오는 내부 함수
    func getHistoryFromUserDefaults() -> [URL: Int] {
        let storedHistory = UserDefaults.standard.object(forKey: historyKey) as? [[String: Int]] ?? []
        return storedHistory.reduce(into: [URL: Int]()) { dict, pair in
            pair.forEach { url, count in
                if let url = URL(string: url) {
                    dict[url] = count
                }
            }
        }
    }
    
    // UserDefaults에서 지정된 인덱스의 URL을 새 URL로 업데이트하는 내부 함수
    func updateHistoryInUserDefaults(at index: Int, with newUrl: URL, shouldPrint: Bool) throws {
        var history = getHistoryFromUserDefaults()
        let sortedKeys = history.keys.sorted(by: { $0.absoluteString < $1.absoluteString })
        guard index >= 0 && index < sortedKeys.count else {
            throw HistoryManagerError.invalidIndex
        }
        let key = sortedKeys[index]
        let visitCount = history.removeValue(forKey: key)
        history[newUrl] = visitCount
        UserDefaults.standard.set(history.map { [$0.key.absoluteString: $0.value] }, forKey: historyKey)
        if shouldPrint {
            print("URL Updated from \(key.absoluteString) to \(newUrl.absoluteString)")
        }
    }
    
    // UserDefaults에서 히스토리 불러오기
    func loadHistoryFromUserDefaults() {
        let _ = getHistoryFromUserDefaults()
    }
    
    // UserDefaults에서 지정된 인덱스의 URL 히스토리를 삭제하는 내부 함수
    private func deleteHistoryFromUserDefaults(at index: Int, shouldPrint: Bool) throws {
        var history = getHistoryFromUserDefaults()
        let sortedKeys = history.keys.sorted(by: { $0.absoluteString < $1.absoluteString }) // URL을 문자열로 비교하여 정렬
        guard index >= 0 && index < sortedKeys.count else {
            throw HistoryManagerError.invalidIndex
        }
        let key = sortedKeys[index]
        history.removeValue(forKey: key)
        UserDefaults.standard.set(history.map { [$0.key.absoluteString: $0.value] }, forKey: historyKey)
        if shouldPrint {
            print("URL Deleted from History at index: \(index)")
        }
    }
}

// Keychain 저장 코드
private extension HistoryManager {
    
    // Keychain에 URL 히스토리를 추가하는 내부 함수
    func addHistoryToKeychain(_ url: URL, shouldPrint: Bool) throws {
        let currentCount = retrieveHistoryCountFromKeychain(url: url.absoluteString) ?? 0
        let newCount = currentCount + 1
        let isSuccess = KeychainManager.shared.save(key: url.absoluteString, value: String(newCount))
        if isSuccess && shouldPrint {
            print("keychain -> URL \(newCount == 1 ? "Added to" : "Updated in") History: \(url.absoluteString)")
        } else if !isSuccess {
            print("Failed to save URL to Keychain: \(url.absoluteString)")
        }
    }
    
    func retrieveHistoryCountFromKeychain(url: String) -> Int? {
          if let value = KeychainManager.shared.retrieve(key: url) {
              return Int(value)
          }
          return nil
      }
    
    func loadHistoryFromKeychain() {
        historyList.removeAll()
        let keys = KeychainManager.shared.getAllKeys()
        for key in keys {
            if let value = KeychainManager.shared.retrieve(key: key), let count = Int(value) {
                if let url = URL(string: key) {
                    historyList[url] = count
                }
            } else {
                print("Failed to retrieve value for key: \(key)")
            }
        }
    }
    
    // Keychain에서 URL 히스토리를 불러오는 내부 함수
    func getHistoryFromKeychain() -> [URL: Int] {
        let keys = KeychainManager.shared.getAllKeys()
        var history = [URL: Int]()
        for key in keys {
            if let value = KeychainManager.shared.retrieve(key: key), let count = Int(value) {
                if let url = URL(string: key) {
                    history[url] = count
                }
            }
        }
        return history
    }
    
    // Keychain에서 삭제
    func deleteHistoryFromKeychain(at index: Int, shouldPrint: Bool) throws {
        let history = getHistoryFromKeychain()
        let sortedKeys = history.keys.sorted(by: { $0.absoluteString < $1.absoluteString })
        guard index >= 0 && index < sortedKeys.count else {
            throw HistoryManagerError.invalidIndex
        }
        let key = sortedKeys[index].absoluteString
        _ = KeychainManager.shared.delete(key: key)
        if shouldPrint {
            print("URL Deleted from Keychain History at index: \(index)")
        }
    }
    
    // Keychain에서 히스토리 업데이트
    func updateHistoryInKeychain(at index: Int, with newUrl: URL, shouldPrint: Bool) throws {
        let history = getHistoryFromKeychain()
        let sortedKeys = history.keys.sorted(by: { $0.absoluteString < $1.absoluteString })
        guard index >= 0 && index < sortedKeys.count else {
            throw HistoryManagerError.invalidIndex
        }
        let oldUrl = sortedKeys[index]
        let visitCount = history[oldUrl]
        _ = KeychainManager.shared.delete(key: oldUrl.absoluteString)
        if let count = visitCount {
            _ = KeychainManager.shared.save(key: newUrl.absoluteString, value: String(count))
        }
        if shouldPrint {
            print("URL Updated in Keychain from \(oldUrl.absoluteString) to \(newUrl.absoluteString)")
        }
    }
    
    func clearHistoryFromKeychain() {
        let keys = KeychainManager.shared.getAllKeys()
        for key in keys {
            _ = KeychainManager.shared.delete(key: key)
        }
    }
}
