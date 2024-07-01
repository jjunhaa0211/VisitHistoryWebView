# VisitHistoryWebView

`VisitHistoryWebView`는 웹 브라우징 히스토리를 관리하는 Swift 라이브러리입니다. 이 클래스는 URL 방문 횟수를 추적하고, 검색 및 히스토리 데이터 관리 기능을 제공합니다.

## 기능

- **URL 추가 및 업데이트**
  - `addHistory(_ url: URL, shouldPrint: Bool = true)`: 지정된 URL을 히스토리에 추가하거나 업데이트합니다. `shouldPrint`를 통해 로그 출력 여부를 제어할 수 있습니다.

- **히스토리 조회**
  - `getHistory() -> [URL]`: 모든 저장된 히스토리 URL을 반환합니다.
  - `getRecentHistory(limit: Int) -> [URL]`: 가장 자주 방문한 URL을 상위 N개까지 반환합니다.
  - `searchHistory(keyword: String) -> [URL]`: 주어진 키워드를 포함하는 URL을 검색합니다.

- **히스토리 수정 및 삭제**
  - `deleteHistory(at index: Int, shouldPrint: Bool = true)`: 지정된 인덱스의 URL을 히스토리에서 삭제합니다.
  - `clearHistory(shouldPrint: Bool = true)`: 모든 히스토리를 삭제합니다.
  - `updateHistory(at index: Int, with newUrl: URL, shouldPrint: Bool = true)`: 지정된 인덱스의 URL을 새로운 URL로 업데이트합니다.

## 에러 처리

`HistoryManager`는 다음과 같은 에러를 정의하고 처리합니다:
- `HistoryManagerError.invalidIndex`: 주어진 인덱스가 유효 범위를 벗어났을 때 발생합니다.

## SPM(Swift Package Manager)만을 지원하고 있습니다.
