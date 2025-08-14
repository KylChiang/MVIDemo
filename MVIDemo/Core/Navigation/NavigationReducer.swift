//
//  NavigationReducer.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/14.
//

import Foundation

// MARK: - 導航 Reducer 協議
/**
 * 定義導航狀態縮減器的協議
 * MVI 架構中的 Reducer 層，負責處理狀態轉換邏輯
 */
protocol NavigationReducerProtocol {
    /// 根據當前狀態和用戶意圖，產生新的導航狀態
    /// - Parameters:
    ///   - state: 當前的導航視圖狀態
    ///   - intent: 用戶的導航意圖
    /// - Returns: 新的導航視圖狀態
    func reduce(state: NavigationViewState, intent: NavigationIntent) -> NavigationViewState
}

/**
 * 導航狀態縮減器的具體實現
 * 處理所有導航相關的狀態轉換邏輯
 */
class NavigationReducer: NavigationReducerProtocol {
    /**
     * 核心的狀態轉換方法
     * 根據不同的導航意圖執行相應的狀態轉換
     */
    func reduce(state: NavigationViewState, intent: NavigationIntent) -> NavigationViewState {
        switch intent {
        case .navigateToAnnouncements:
            // 直接導航到公告（無需安全驗證的情況）
            return NavigationViewState(
                currentState: .announcements,
                isSecurityVerificationRequired: false,
                pendingDestination: nil
            )
            
        case .requestSecureAccess(let destination):
            // 請求安全訪問，先顯示安全驗證頁面
            return NavigationViewState(
                currentState: .securityVerification(destination: destination),
                isSecurityVerificationRequired: true,
                pendingDestination: destination
            )
            
        case .securityVerificationSuccess(let destination):
            // 安全驗證成功，導航到目標頁面
            switch destination {
            case .announcements:
                return NavigationViewState(
                    currentState: .announcements,
                    isSecurityVerificationRequired: false,
                    pendingDestination: nil
                )
            case .settings, .userProfile:
                // 未來可擴展其他頁面
                return NavigationViewState(
                    currentState: .none,
                    isSecurityVerificationRequired: false,
                    pendingDestination: nil
                )
            }
            
        case .securityVerificationFailed:
            // 安全驗證失敗，回到初始狀態
            return NavigationViewState(
                currentState: .none,
                isSecurityVerificationRequired: false,
                pendingDestination: nil
            )
            
        case .dismissCurrentNavigation:
            // 關閉當前導航
            return NavigationViewState(
                currentState: .none,
                isSecurityVerificationRequired: false,
                pendingDestination: nil
            )
            
        case .reset:
            // 重置所有導航狀態
            return .initial
        }
    }
}
