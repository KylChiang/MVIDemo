//
//  NavigationIntent.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/14.
//

import Foundation

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
