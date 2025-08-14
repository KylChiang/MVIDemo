//
//  NavigationState.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/13.
//

import Foundation

// MARK: - 導航狀態定義
/**
 * 定義應用程式中所有可能的導航狀態
 * 使用 MVI 架構模式管理複雜的導航邏輯
 */
enum NavigationState: Equatable {
    /// 無導航狀態 - 在主畫面或其他非導航頁面
    case none
    
    /// 公告頁面 - 直接顯示公告列表
    case announcements
    
    /// 安全驗證頁面 - 顯示驗證頁面並保存目標導航
    case securityVerification(destination: SecureDestination)
    
    /**
     * 需要安全驗證的目標頁面
     * 定義哪些頁面需要額外的安全驗證才能訪問
     */
    enum SecureDestination: Equatable {
        /// 需要安全驗證的公告頁面
        case announcements
        
        /// 設定頁面 (未來擴展)
        case settings
        
        /// 用戶資料頁面 (未來擴展)
        case userProfile
        
        // 可依需求繼續擴展其他需要安全驗證的頁面
    }
}

// MARK: - 導航 Intent
/**
 * 定義所有可能的導航操作意圖
 * MVI 架構中的 Intent 層，表示用戶的導航行為
 */
enum NavigationIntent {
    /// 直接導航到公告頁面 (跳過安全驗證)
    case navigateToAnnouncements
    
    /// 請求安全訪問特定目標頁面
    case requestSecureAccess(destination: NavigationState.SecureDestination)
    
    /// 安全驗證成功，準備導航到目標頁面
    case securityVerificationSuccess(destination: NavigationState.SecureDestination)
    
    /// 安全驗證失敗
    case securityVerificationFailed
    
    /// 關閉當前導航 (例如用戶點擊返回按鈕)
    case dismissCurrentNavigation
    
    /// 重置所有導航狀態到初始狀態
    case reset
}

// MARK: - 導航視圖狀態
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