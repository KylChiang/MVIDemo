//
//  NavigationViewState.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/14.
//

import Foundation

// MARK: - 導航視圖 ViewState 狀態
/**
 * 管理導航相關的 UI 狀態
 * 包含當前導航狀態和用於決定 UI 顯示的計算屬性
 */
struct NavigationViewState: Equatable {
    /// 當前的導航狀態
    let currentState: NavigationState
    
    /// 是否需要安全驗證 (用於 UI 顯示邏輯)
    let isSecurityVerificationRequired: Bool
    
    /// 等待跳轉的目標頁面 (安全驗證成功後的導航目標)
    let pendingDestination: NavigationState.SecureDestination?
    
    /// 初始狀態 - 應用程式啟動時的預設導航狀態
    static let initial = NavigationViewState(
        currentState: .none,
        isSecurityVerificationRequired: false,
        pendingDestination: nil
    )
    
    // MARK: - 便利計算屬性 (用於 UI 綁定)
    
    /// 是否應該顯示公告頁面
    /// 當 currentState == .announcements 時為 true
    var shouldShowAnnouncements: Bool {
        currentState == .announcements
    }
    
    /// 是否應該顯示安全驗證頁面
    /// 當 currentState 為 .securityVerification 時為 true
    var shouldShowSecurityVerification: Bool {
        if case .securityVerification = currentState {
            return true
        }
        return false
    }
}
