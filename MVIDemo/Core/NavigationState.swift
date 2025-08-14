//
//  NavigationState.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/13.
//

import Foundation

// MARK: - 導航狀態定義
enum NavigationState: Equatable {
    case none
    case announcements
    case securityVerification(destination: SecureDestination)
    
    enum SecureDestination: Equatable {
        case announcements
        // 未來可擴展其他需要安全驗證的頁面
        case settings
        case userProfile
    }
}

// MARK: - 導航 Intent
enum NavigationIntent {
    case navigateToAnnouncements
    case requestSecureAccess(destination: NavigationState.SecureDestination)
    case securityVerificationSuccess(destination: NavigationState.SecureDestination)
    case securityVerificationFailed
    case dismissCurrentNavigation
    case reset
}

// MARK: - 導航狀態
struct NavigationViewState: Equatable {
    let currentState: NavigationState
    let isSecurityVerificationRequired: Bool
    let pendingDestination: NavigationState.SecureDestination?
    
    static let initial = NavigationViewState(
        currentState: .none,
        isSecurityVerificationRequired: false,
        pendingDestination: nil
    )
    
    // 便利計算屬性
    var shouldShowAnnouncements: Bool {
        currentState == .announcements
    }
    
    var shouldShowSecurityVerification: Bool {
        if case .securityVerification = currentState {
            return true
        }
        return false
    }
}

// MARK: - 導航 Reducer
protocol NavigationReducerProtocol {
    func reduce(state: NavigationViewState, intent: NavigationIntent) -> NavigationViewState
}

class NavigationReducer: NavigationReducerProtocol {
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