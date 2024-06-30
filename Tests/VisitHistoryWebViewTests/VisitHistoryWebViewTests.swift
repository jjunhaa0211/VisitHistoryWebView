import XCTest
@testable import VisitHistoryWebView

class HistoryManagerTests: XCTestCase {

    override func setUpWithError() throws {
        HistoryManager.shared.clearHistory()
    }

    override func tearDownWithError() throws {
        HistoryManager.shared.clearHistory()
    }

    // URL을 추가할 수 있는지 확인하는 테스트
    func testAddHistory() throws {
        let url = URL(string: "https://www.google.com/?hl=ko")!
        try HistoryManager.shared.addHistory(url)
        
        let history = HistoryManager.shared.getHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first, url)
    }

    // 중복된 URL이 추가되지 않는지 확인하는 테스트
    func testAddDuplicateHistory() throws {
        let url = URL(string: "https://www.google.com/?hl=ko")!
        try HistoryManager.shared.addHistory(url)
        
        try HistoryManager.shared.addHistory(url)
        
        let history = HistoryManager.shared.getHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first, url)
        XCTAssertEqual(HistoryManager.shared.historyList[url], 2)
    }

    // 유효하지 않은 인덱스를 삭제 시도할 때 예외가 발생하는지 확인하는 테스트
    func testDeleteHistoryOutOfBounds() throws {
        let url = URL(string: "https://www.google.com/?hl=ko")!
        try HistoryManager.shared.addHistory(url)
        
        XCTAssertThrowsError(try HistoryManager.shared.deleteHistory(at: 1)) { error in
            XCTAssertEqual(error as? HistoryManagerError, HistoryManagerError.invalidIndex)
        }
        
        let history = HistoryManager.shared.getHistory()
        XCTAssertEqual(history.count, 1)
    }

    // 모든 히스토리를 삭제할 수 있는지 확인하는 테스트
    func testClearHistory() throws {
        let url1 = URL(string: "https://www.google.com/?hl=ko")!
        let url2 = URL(string: "https://www.example.com")!
        try HistoryManager.shared.addHistory(url1)
        try HistoryManager.shared.addHistory(url2)
        
        HistoryManager.shared.clearHistory()
        
        let history = HistoryManager.shared.getHistory()
        XCTAssertTrue(history.isEmpty)
    }
    
    // URL 방문 횟수를 증가시키는지 확인하는 테스트
    func testVisitCountIncrease() throws {
        let url = URL(string: "https://www.google.com/?hl=ko")!
        try HistoryManager.shared.addHistory(url)
        try HistoryManager.shared.addHistory(url)
        
        let history = HistoryManager.shared.getHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(HistoryManager.shared.historyList[url], 2)
    }
    
    // 특정 URL을 검색할 수 있는지 확인하는 테스트
    func testSearchHistory() throws {
        let url1 = URL(string: "https://www.google.com/?hl=ko")!
        let url2 = URL(string: "https://www.example.com")!
        try HistoryManager.shared.addHistory(url1)
        try HistoryManager.shared.addHistory(url2)
        
        let searchResult = HistoryManager.shared.searchHistory(keyword: "google")
        XCTAssertEqual(searchResult.count, 1)
        XCTAssertEqual(searchResult.first, url1)
    }
    
    // 최근 방문한 URL 목록을 가져올 수 있는지 확인하는 테스트
    func testGetRecentHistory() throws {
        let url1 = URL(string: "https://www.google.com/?hl=ko")!
        let url2 = URL(string: "https://www.example.com")!
        try HistoryManager.shared.addHistory(url1)
        try HistoryManager.shared.addHistory(url2)
        
        let recentHistory = HistoryManager.shared.getRecentHistory(limit: 1)
        XCTAssertEqual(recentHistory.count, 1)
        XCTAssertEqual(recentHistory.first, url2)
    }
    
    // URL을 업데이트할 수 있는지 확인하는 테스트
    func testUpdateHistory() throws {
        let url1 = URL(string: "https://www.google.com/?hl=ko")!
        let url2 = URL(string: "https://www.example.com")!
        try HistoryManager.shared.addHistory(url1)
        
        try HistoryManager.shared.updateHistory(at: 0, with: url2)
        
        let history = HistoryManager.shared.getHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first, url2)
    }
}
