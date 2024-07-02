![asdf](https://github.com/jjunhaa0211/VisitHistoryWebView/assets/102890390/92e9f6dd-55df-4425-839d-ad92886187a4)

# VisitHistoryWebView

`VisitHistoryWebView`는 웹 브라우징 히스토리를 관리하는 Swift 라이브러리입니다. 이 클래스는 URL 방문 횟수를 추적하고, 검색 및 히스토리 데이터 관리 기능을 제공합니다.
## 기능 사용 방법

### URL 추가

URL 방문 이력을 추가하려면 `addHistory` 메서드를 사용합니다. 이 메서드는 URL 객체와 선택적으로 출력 여부를 인자로 받습니다.

```swift
try historyManager.addHistory(URL(string: "https://example.com")!, shouldPrint: true)
```

### 이력 조회

저장된 모든 URL을 조회하려면 `getHistory` 메서드를 사용합니다.

```swift
let urls = historyManager.getHistory()
print(urls)
```

### URL 업데이트

지정된 인덱스의 URL을 새 URL로 업데이트하려면 `updateHistory` 메서드를 사용합니다.

```swift
try historyManager.updateHistory(at: 0, with: URL(string: "https://newexample.com")!, shouldPrint: true)
```

### URL 삭제

지정된 인덱스의 URL을 삭제하려면 `deleteHistory` 메서드를 사용합니다.

```swift
try historyManager.deleteHistory(at: 0, shouldPrint: true)
```

### 전체 이력 삭제

모든 방문 이력을 삭제하려면 `clearHistory` 메서드를 사용합니다.

```swift
historyManager.clearHistory(shouldPrint: true)
```

### 이력 검색

특정 키워드를 포함하는 URL을 찾으려면 `searchHistory` 메서드를 사용합니다.

```swift
let searchResults = historyManager.searchHistory(keyword: "example")
print(searchResults)
```

### 자주 방문된 URL 조회

가장 자주 방문된 URL을 지정된 수만큼 조회하려면 `getRecentHistory` 메서드를 사용합니다.

```swift
let recentUrls = historyManager.getRecentHistory(limit: 5)
print(recentUrls)
```

## KeychainManager

### 데이터 저장

Keychain에 데이터를 저장하려면 `save` 메서드를 사용합니다. 이 메서드는 키와 값을 인자로 받습니다.

```swift
let success = KeychainManager.shared.save(key: "exampleKey", value: "exampleValue")
print("Save successful: \(success)")
```

### 데이터 검색

Keychain에서 데이터를 검색하려면 `retrieve` 메서드를 사용합니다.

```swift
if let value = KeychainManager.shared.retrieve(key: "exampleKey") {
    print("Retrieved value: \(value)")
}
```

### 데이터 삭제

Keychain에서 데이터를 삭제하려면 `delete` 메서드를 사용합니다.

```swift
let deleteSuccess = KeychainManager.shared.delete(key: "exampleKey")
print("Delete successful: \(deleteSuccess)")
```
