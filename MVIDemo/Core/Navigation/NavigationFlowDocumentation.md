# 導航系統架構說明 (Navigation System Architecture)

## 概述
本專案使用 **MVI (Model-View-Intent)** 架構模式實現複雜的導航系統，支援需要安全驗證的頁面訪問流程。

## 核心組件

### 1. NavigationState (導航狀態)
定義應用程式中所有可能的導航狀態：
- `none`: 無導航狀態 (主畫面)
- `announcements`: 公告頁面
- `securityVerification(destination:)`: 安全驗證頁面

### 2. NavigationIntent (導航意圖)
定義所有可能的導航操作：
- `navigateToAnnouncements`: 直接導航到公告
- `requestSecureAccess(destination:)`: 請求安全訪問
- `securityVerificationSuccess(destination:)`: 驗證成功
- `securityVerificationFailed`: 驗證失敗
- `dismissCurrentNavigation`: 關閉當前導航
- `reset`: 重置狀態

### 3. NavigationManager (導航管理器)
MVI 架構的核心控制器，負責：
- 狀態管理 (使用 @Published 支援 SwiftUI 自動更新)
- 意圖處理 (將用戶操作轉換為狀態變更)
- 副作用處理 (Toast 通知、震動回饋等)

## 導航流程

### 安全驗證流程
```
用戶點擊"查看公告" 
    ↓
requestSecureAnnouncementsAccess()
    ↓
狀態變更: .none → .securityVerification(destination: .announcements)
    ↓
顯示 SecurityVerificationView
    ↓
[用戶完成驗證]
    ↓
securityVerificationSucceeded(for: .announcements)
    ↓
狀態變更: .securityVerification → .announcements
    ↓
顯示 AnnouncementsView
    ↓
[用戶點擊返回]
    ↓
resetNavigation()
    ↓
狀態變更: .announcements → .none
```

## UI 整合 (HomeView.swift)

### Sheet 綁定
使用計算屬性決定 Sheet 的顯示：
- `shouldShowSecurityVerification`: 控制安全驗證頁面
- `shouldShowAnnouncements`: 控制公告頁面

### 關鍵修復
**問題**: 公告頁面返回按鈕沒有反應
**原因**: AnnouncementsView 使用 `Environment(\.dismiss)` 只關閉 Sheet，但沒有重置 NavigationManager 狀態
**解決**: 傳入 `onDismiss` 回調，確保正確呼叫 `navigationManager.resetNavigation()`

## 狀態同步機制

### MVI 單向資料流
```
Intent → Reducer → State → UI → Intent
```

### 狀態計算屬性
```swift
var shouldShowAnnouncements: Bool {
    currentState == .announcements
}

var shouldShowSecurityVerification: Bool {
    if case .securityVerification = currentState {
        return true
    }
    return false
}
```

## 副作用系統

### NavigationEffect
定義導航相關的一次性效果：
- `showSecurityPrompt`: 顯示安全驗證提示
- `showNavigationSuccess`: 顯示導航成功訊息
- `showSecurityError`: 顯示安全錯誤訊息
- `showDismissalConfirmation`: 顯示取消確認訊息
- `hapticFeedback`: 觸發震動回饋

## 擴展性設計

### 新增安全驗證頁面
1. 在 `SecureDestination` 中添加新的 case
2. 在 `NavigationReducer` 中處理新的目標
3. 在 HomeView 中添加對應的 Sheet

### 新增導航意圖
1. 在 `NavigationIntent` 中添加新的 case
2. 在 `NavigationReducer.reduce()` 中處理新的意圖
3. 在 `NavigationManager` 中添加便利方法

## 最佳實務

1. **狀態不可變性**: 所有狀態變更都通過 Reducer 進行
2. **單一責任**: 每個組件都有明確的職責
3. **可測試性**: 純函數的 Reducer 易於單元測試
4. **可預測性**: 狀態變更邏輯集中且透明
5. **解耦合**: UI 邏輯與業務邏輯分離

## 偵錯技巧

1. 在 `NavigationManager.handle()` 中添加日誌
2. 觀察 `@Published state` 的變化
3. 檢查 Sheet 的 `isPresented` 綁定
4. 確認回調函數正確傳遞和呼叫