// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import WebKit

enum HistoryManagerError: Error {
    case urlAlreadyExists
    case invalidIndex
}

open class HistoryManager {
    public static let shared = HistoryManager()
    public var historyList = [URL: Int]()
    
    private init() {}
    
    open func addHistory(_ url: URL) throws {
        if let count = historyList[url] {
            historyList[url] = count + 1
            print("Increase the number of URL visits: \(url.absoluteString), Number of visits: \(count + 1)")
        } else {
            historyList[url] = 1
            print("URL Added to History: \(url.absoluteString)")
        }
    }
    
    open func getHistory() -> [URL] {
        return Array(historyList.keys)
    }
    
    open func getRecentHistory(limit: Int) -> [URL] {
        let sortedHistory = historyList.sorted { $0.value > $1.value }
        return Array(sortedHistory.prefix(limit).map { $0.key })
    }
    
    open func searchHistory(keyword: String) -> [URL] {
        return historyList.keys.filter { $0.absoluteString.contains(keyword) }
    }
    
    open func deleteHistory(at index: Int) throws {
        guard index >= 0 && index < historyList.count else {
            throw HistoryManagerError.invalidIndex
        }
        let key = Array(historyList.keys)[index]
        historyList.removeValue(forKey: key)
        print("URL Deleted from History at index: \(index)")
    }
    
    open func clearHistory() {
        historyList.removeAll()
        print("All history cleared")
    }
    
    open func updateHistory(at index: Int, with newUrl: URL) throws {
        guard index >= 0 && index < historyList.count else {
            throw HistoryManagerError.invalidIndex
        }
        let key = Array(historyList.keys)[index]
        let visitCount = historyList.removeValue(forKey: key)
        historyList[newUrl] = visitCount
        print("URL Updated from \(key.absoluteString) to \(newUrl.absoluteString)")
    }
}

