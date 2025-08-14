//
//  NavigationState.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/13.
//

import Foundation

// MARK: - 導航狀態 State 定義
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
