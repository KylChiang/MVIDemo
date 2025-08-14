//
//  NavigationManager.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/13.
//

import Foundation

// MARK: - Navigation Manager
/**
 * 導航管理器 - MVI 架構中的核心控制器
 * 負責管理整個應用程式的導航狀態和流程
 * 副作用處理機制: 將用戶意圖轉換為狀態變更，並處理相關的副作用
 */
class NavigationManager: ModelProtocol, ObservableObject {
    typealias Intent = NavigationIntent
    typealias State = NavigationViewState
    
    /// 當前的導航狀態，使用 @Published 以供 SwiftUI 自動更新 UI
    @Published private(set) var state = NavigationViewState.initial
    
    /// 狀態縮減器 - 負責處理狀態轉換邏輯
    private let reducer: NavigationReducerProtocol
    
    /// 副作用處理器 - 負責處理 Toast、震動等一次性效果
    private let effectHandler: EffectHandler
    
    /**
     * 初始化導航管理器
     * - Parameters:
     *   - reducer: 狀態縮減器，負責處理狀態轉換
     *   - effectHandler: 副作用處理器，負責處理一次性效果
     */
    init(
        reducer: NavigationReducerProtocol,
        effectHandler: EffectHandler
    ) {
        self.reducer = reducer
        self.effectHandler = effectHandler
    }
    
    /**
     * 處理導航意圖的核心方法
     * 將用戶意圖轉換為新的狀態，並處理相關的副作用
     * - Parameter intent: 用戶的導航意圖
     */
    func handle(_ intent: NavigationIntent) {
        let previousState = state
        // 使用 reducer 產生新的狀態
        state = reducer.reduce(state: state, intent: intent)
        
        // 處理狀態變更的副作用 (例如 Toast 通知、震動回饋)
        handleStateTransition(from: previousState, to: state, intent: intent)
    }
    
    /**
     * 處理狀態轉換的副作用
     * 根據不同的意圖類型觸發相應的一次性效果
     * - Parameters:
     *   - previousState: 之前的導航狀態
     *   - newState: 新的導航狀態
     *   - intent: 觸發狀態變更的意圖
     */
    private func handleStateTransition(
        from previousState: NavigationViewState,
        to newState: NavigationViewState,
        intent: NavigationIntent
    ) {
        switch intent {
        case .requestSecureAccess:
            // 請求安全訪問時顯示提示
            effectHandler.handle(NavigationEffect.showSecurityPromptToast.toEffect())
            
        case .securityVerificationSuccess:
            // 驗證成功時顯示成功訊息和震動回饋
            effectHandler.handle(NavigationEffect.showNavigationSuccessToast.toEffect())
            effectHandler.handle(NavigationEffect.hapticFeedback.toEffect())
            
        case .securityVerificationFailed:
            // 驗證失敗時顯示錯誤訊息
            effectHandler.handle(NavigationEffect.showSecurityErrorToast.toEffect())
            
        case .dismissCurrentNavigation:
            // 取消導航時顯示確認訊息
            effectHandler.handle(NavigationEffect.showDismissalConfirmationToast.toEffect())
            
        default:
            // 其他意圖不需要特殊的副作用處理
            break
        }
    }
    
    // MARK: - 便利方法 (Convenience Methods)
    
    /**
     * 請求訪問公告頁面（需要安全驗證）
     * 這是主要的導航入口，用戶點擊“查看公告”按鈕時觸發
     */
    func requestSecureAnnouncementsAccess() {
        handle(.requestSecureAccess(destination: .announcements))
    }
    
    /**
     * 直接導航到公告頁面（跳過安全驗證）
     * 用於特殊情況下的快速訪問
     */
    func navigateToAnnouncements() {
        handle(.navigateToAnnouncements)
    }
    
    /**
     * 安全驗證成功後的回調
     * 由 SecurityVerificationView 在驗證成功時呼叫
     * - Parameter destination: 驗證成功後要導航的目標頁面
     */
    func securityVerificationSucceeded(for destination: NavigationState.SecureDestination) {
        handle(.securityVerificationSuccess(destination: destination))
    }
    
    /**
     * 安全驗證失敗的回調
     * 由 SecurityVerificationView 在驗證失敗時呼叫
     */
    func securityVerificationFailed() {
        handle(.securityVerificationFailed)
    }
    
    /**
     * 關閉當前導航
     * 用於用戶主動取消或關閉導航的情況
     */
    func dismissCurrentNavigation() {
        handle(.dismissCurrentNavigation)
    }
    
    /**
     * 重置導航狀態到初始狀態
     * 用於頁面關閉時清理狀態，防止狀態殘留
     */
    func resetNavigation() {
        handle(.reset)
    }
}

// MARK: - 導航副作用 (Navigation Effects)
/**
 * 定義導航相關的一次性副作用
 * 這些效果不影響狀態，但提供給用戶反饋
 */
enum NavigationEffect {
    /// 顯示安全驗證提示
    case showSecurityPromptToast
    
    /// 顯示導航成功訊息
    case showNavigationSuccessToast
    
    /// 顯示安全錯誤訊息
    case showSecurityErrorToast
    
    /// 顯示取消確認訊息
    case showDismissalConfirmationToast
    
    /// 觸發震動回饋
    case hapticFeedback
    
    /**
     * 將導航效果轉換為通用的 Effect 物件
     * - Returns: 相應的 Effect 實例 (如 ToastEffect、HapticEffect)
     */
    func toEffect() -> Effect {
        switch self {
        case .showSecurityPromptToast:
            return ToastEffect(message: "需要安全驗證", duration: 1.0)
        case .showNavigationSuccessToast:
            return ToastEffect(message: "驗證成功，正在跳轉", duration: 1.0)
        case .showSecurityErrorToast:
            return ToastEffect(message: "驗證失敗", duration: 2.0)
        case .showDismissalConfirmationToast:
            return ToastEffect(message: "已取消操作", duration: 1.0)
        case .hapticFeedback:
            return HapticEffect(type: .light)
        }
    }
}
