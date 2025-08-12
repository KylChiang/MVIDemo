# MVIDemo - SwiftUI MVI 架構範例專案

本專案展示了在 SwiftUI 中實現 MVI (Model-View-Intent) 架構模式的完整範例，包含登入、首頁與公告功能。

## 📋 目錄

- [專案架構](#專案架構)
- [分層說明](#分層說明)
- [元件使用方式](#元件使用方式)
- [開發規範](#開發規範)
- [測試](#測試)
- [專案設置](#專案設置)

## 🏗️ 專案架構

```
MVIDemo/
├── Core/                           # 核心層 - MVI 架構核心元件
│   ├── Model.swift                 # ModelProtocol 定義
│   └── Effect.swift               # Effect 處理機制
├── Domain/                        # 領域層 - 業務邏輯
│   ├── Entity/                    # 實體類別
│   │   ├── User.swift
│   │   └── Announcement.swift
│   ├── Repository/                # Repository 介面
│   │   ├── AuthRepository.swift
│   │   └── AnnouncementRepository.swift
│   ├── UseCase/                   # 用例（業務邏輯）
│   │   ├── LoginUseCase.swift
│   │   ├── LogoutUseCase.swift
│   │   ├── GetCurrentUserUseCase.swift
│   │   ├── FetchAnnouncementsUseCase.swift
│   │   └── AccountValidationUseCase.swift
│   └── ValueObject/               # 值物件
├── Data/                          # 資料層 - 外部資料存取
│   ├── AuthRepositoryImpl.swift   # 認證資料實作
│   └── AnnouncementRepositoryImpl.swift # 公告資料實作
├── Features/                      # 功能層 - UI 功能模組
│   ├── Login/                     # 登入功能
│   │   ├── LoginIntent.swift      # 意圖定義
│   │   ├── LoginState.swift       # 狀態定義
│   │   ├── LoginReducer.swift     # 狀態歸納器
│   │   ├── LoginEffect.swift      # 副作用處理
│   │   ├── LoginModel.swift       # MVI 模型
│   │   └── LoginView.swift        # SwiftUI 視圖
│   ├── Home/                      # 首頁功能
│   │   ├── HomeIntent.swift
│   │   ├── HomeState.swift
│   │   ├── HomeReducer.swift
│   │   ├── HomeEffect.swift
│   │   ├── HomeModel.swift
│   │   └── HomeView.swift
│   └── Announcements/             # 公告功能
│       ├── AnnouncementsIntent.swift
│       ├── AnnouncementsState.swift
│       ├── AnnouncementsReducer.swift
│       ├── AnnouncementsEffect.swift
│       ├── AnnouncementsModel.swift
│       └── AnnouncementsView.swift
├── DependencyContainer.swift      # 依賴注入容器
├── ContentView.swift              # 主視圖
└── MVIDemoApp.swift              # App 進入點
```

### 架構圖

![MVI Architecture](MVIDemo_Architecture.puml)

專案採用完整的 MVI 架構，包含以下核心概念：

- **Intent**: 描述用戶意圖或系統事件
- **Model**: 管理狀態和業務邏輯流程
- **View**: 純粹的 UI 呈現層
- **State**: 不可變的狀態描述
- **Reducer**: 純函數狀態計算
- **Effect**: 副作用處理（導航、提示等）

## 📚 分層說明

### Core Layer (核心層)
負責定義 MVI 架構的核心協議和機制。

**主要元件:**
- `ModelProtocol`: 定義 MVI 模型的基本介面
- `Effect`: 副作用處理機制
- `EffectHandler`: 效果執行器

### Domain Layer (領域層)
包含純粹的業務邏輯，不依賴任何外部框架。

**主要元件:**
- **Entity**: 業務實體（User, Announcement）
- **Repository**: 資料存取介面
- **UseCase**: 具體業務用例實作

### Data Layer (資料層)
實作 Domain 層定義的 Repository 介面，處理實際的資料存取。

### Features Layer (功能層)
基於 MVI 模式實作的 UI 功能模組。

## 🎯 元件使用方式

### 1. Intent (意圖)

Intent 描述所有可能的用戶操作或系統事件：

```swift
enum LoginIntent {
    case accountChanged(String)
    case loginClicked
    case loginSuccess(User)
    case loginFailure(Error)
    case clearError
}
```

**使用規範:**
- 只描述「要做什麼」，不包含處理邏輯
- 使用動詞 + 名詞的命名方式
- 包含所有必要的參數

### 2. State (狀態)

State 為不可變的資料結構，描述 UI 的完整狀態：

```swift
struct LoginState {
    let account: String
    let isLoading: Bool
    let isLoginEnabled: Bool
    let errorMessage: String?
    let user: User?
    
    static let initial = LoginState(
        account: "",
        isLoading: false,
        isLoginEnabled: false,
        errorMessage: nil,
        user: nil
    )
}
```

**使用規範:**
- 使用 `struct` 確保不可變性
- 提供 `initial` 靜態屬性作為初始狀態
- 屬性命名清晰明確

### 3. Reducer (歸納器)

Reducer 為純函數，負責根據 Intent 計算新的 State：

```swift
protocol LoginReducerProtocol {
    func reduce(state: LoginState, intent: LoginIntent) -> LoginState
}

class LoginReducer: LoginReducerProtocol {
    func reduce(state: LoginState, intent: LoginIntent) -> LoginState {
        switch intent {
        case .accountChanged(let account):
            return LoginState(
                account: account,
                isLoading: state.isLoading,
                isLoginEnabled: !account.isEmpty,
                errorMessage: nil,
                user: state.user
            )
        // 其他 case...
        }
    }
}
```

**使用規範:**
- 必須為純函數，無副作用
- 不進行網路請求或資料庫操作
- 不處理導航或 UI 動畫

### 4. Model (模型)

Model 是 MVI 的核心，負責協調所有元件：

```swift
class LoginModel: ModelProtocol, ObservableObject {
    @Published private(set) var state = LoginState.initial
    
    private let reducer: LoginReducerProtocol
    private let loginUseCase: LoginUseCase
    private let effectHandler: EffectHandler
    
    func handle(_ intent: LoginIntent) {
        switch intent {
        case .loginClicked:
            state = reducer.reduce(state: state, intent: intent)
            Task {
                // 執行業務邏輯
                let user = try await loginUseCase.execute(account: state.account)
                handle(.loginSuccess(user))
                effectHandler.handle(LoginEffect.navigateToHome.toEffect())
            }
        default:
            state = reducer.reduce(state: state, intent: intent)
        }
    }
}
```

**使用規範:**
- 繼承 `ModelProtocol` 和 `ObservableObject`
- 使用 `@Published private(set)` 發佈狀態
- 決定何時呼叫 UseCase 和觸發 Effect

### 5. Effect (副作用)

Effect 處理不屬於狀態管理的操作：

```swift
enum LoginEffect {
    case showLoginSuccess
    case showLoginError(String)
    case navigateToHome
    case hapticFeedback
    
    func toEffect() -> Effect {
        switch self {
        case .navigateToHome:
            return NavigationEffect(destination: HomeView())
        case .showLoginError(let message):
            return AlertEffect(title: "錯誤", message: message)
        // 其他實作...
        }
    }
}
```

**使用規範:**
- 處理導航、提示、震動等副作用
- 不修改應用狀態
- 提供 `toEffect()` 方法轉換為具體實作

### 6. View (視圖)

View 為純粹的 UI 呈現層：

```swift
struct LoginView: View {
    @StateObject private var model: LoginModel
    @Binding private var isLoggedIn: Bool
    
    init(model: LoginModel, isLoggedIn: Binding<Bool>) {
        self._model = StateObject(wrappedValue: model)
        self._isLoggedIn = isLoggedIn
    }
    
    var body: some View {
        VStack {
            TextField("帳號", text: .constant(model.state.account))
                .onChange(of: model.state.account) { newValue in
                    model.handle(.accountChanged(newValue))
                }
            
            Button("登入") {
                model.handle(.loginClicked)
            }
            .disabled(!model.state.isLoginEnabled)
        }
    }
}
```

**使用規範:**
- 透過 `model.handle(_:)` 發送 Intent
- 只根據 `model.state` 渲染 UI
- 不包含業務邏輯

## 📝 開發規範

### 命名規範

1. **Intent 命名**
   - 使用動詞 + 名詞：`loginClicked`, `accountChanged`
   - 成功/失敗事件：`loginSuccess`, `loginFailure`

2. **State 屬性命名**
   - 布林值使用 `is` 前綴：`isLoading`, `isEnabled`
   - 集合使用複數：`announcements`, `errors`

3. **UseCase 命名**
   - 動詞 + 名詞 + UseCase：`LoginUseCase`, `FetchAnnouncementsUseCase`

4. **Effect 命名**
   - 動詞 + 目標：`navigateToHome`, `showError`

### 程式碼規範

1. **檔案結構**
   - 每個功能獨立資料夾
   - 按照 MVI 元件分類檔案
   - 使用統一的檔案命名規範

2. **依賴注入**
   - 透過 `DependencyContainer` 管理依賴
   - 介面與實作分離
   - 支援測試注入

3. **錯誤處理**
   - 使用 Swift 的 `Error` 協議
   - 在 UseCase 層處理業務錯誤
   - 透過 Effect 顯示錯誤訊息

4. **非同步處理**
   - 使用 `async/await` 處理非同步操作
   - 在 Model 中使用 `Task` 處理非同步 Intent
   - 確保 UI 更新在 Main Thread

### 資料流規範

1. **單向資料流**
   ```
   View -> Intent -> Model -> UseCase -> Reducer -> State -> View
   ```

2. **副作用處理**
   ```
   Model -> Effect -> EffectHandler -> 實際執行
   ```

3. **測試策略**
   - Unit Test: UseCase, Reducer
   - Integration Test: Model
   - UI Test: View

## 🧪 測試

### 執行測試

```bash
# 執行所有測試
xcodebuild test -scheme MVIDemo -destination 'platform=iOS Simulator,name=iPhone 15'

# 執行單元測試
xcodebuild test -scheme MVIDemo -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing MVIDemoTests
```

### 測試架構

- **MVIDemoTests/**: Unit Tests
  - UseCase 測試
  - Reducer 測試
  - Model 測試

- **MVIDemoUITests/**: UI Tests
  - 端到端流程測試

## 🚀 專案設置

### 環境需求

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### 安裝步驟

1. 克隆專案：
   ```bash
   git clone [repository-url]
   cd MVIDemo
   ```

2. 開啟專案：
   ```bash
   open MVIDemo.xcodeproj
   ```

3. 編譯並執行：
   - 選擇目標裝置或模擬器
   - 按 `Cmd + R` 執行

### 依賴管理

本專案不使用外部依賴，完全基於 SwiftUI 和 Foundation 框架實作。

## 📖 參考資料

- [MVI Architecture Pattern](https://hannesdorfmann.com/android/model-view-intent/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

© 2025 MVIDemo. 此專案僅供學習和參考使用。
