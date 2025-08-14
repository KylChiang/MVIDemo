//
//  NavigationManager.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/13.
//

import Foundation

// MARK: - Navigation Manager
class NavigationManager: ModelProtocol, ObservableObject {
    typealias Intent = NavigationIntent
    typealias State = NavigationViewState
    
    @Published private(set) var state = NavigationViewState.initial
    
    private let reducer: NavigationReducerProtocol
    private let effectHandler: EffectHandler
    
    init(
        reducer: NavigationReducerProtocol,
        effectHandler: EffectHandler
    ) {
        self.reducer = reducer
        self.effectHandler = effectHandler
    }
    
    func handle(_ intent: NavigationIntent) {
        let previousState = state
        state = reducer.reduce(state: state, intent: intent)
        
        // 處理狀態變更的副作用
        handleStateTransition(from: previousState, to: state, intent: intent)
    }
    
    private func handleStateTransition(
        from previousState: NavigationViewState,
        to newState: NavigationViewState,
        intent: NavigationIntent
    ) {
        switch intent {
        case .requestSecureAccess:
            effectHandler.handle(NavigationEffect.showSecurityPrompt.toEffect())
            
        case .securityVerificationSuccess:
            effectHandler.handle(NavigationEffect.showNavigationSuccess.toEffect())
            effectHandler.handle(NavigationEffect.hapticFeedback.toEffect())
            
        case .securityVerificationFailed:
            effectHandler.handle(NavigationEffect.showSecurityError.toEffect())
            
        case .dismissCurrentNavigation:
            effectHandler.handle(NavigationEffect.showDismissalConfirmation.toEffect())
            
        default:
            break
        }
    }
    
    // MARK: - Convenience Methods
    
    /// 請求訪問公告（需要安全驗證）
    func requestSecureAnnouncementsAccess() {
        handle(.requestSecureAccess(destination: .announcements))
    }
    
    /// 直接導航到公告（無需安全驗證）
    func navigateToAnnouncements() {
        handle(.navigateToAnnouncements)
    }
    
    /// 安全驗證成功
    func securityVerificationSucceeded(for destination: NavigationState.SecureDestination) {
        handle(.securityVerificationSuccess(destination: destination))
    }
    
    /// 安全驗證失敗
    func securityVerificationFailed() {
        handle(.securityVerificationFailed)
    }
    
    /// 關閉當前導航
    func dismissCurrentNavigation() {
        handle(.dismissCurrentNavigation)
    }
    
    /// 重置導航狀態
    func resetNavigation() {
        handle(.reset)
    }
}

// MARK: - Navigation Effects
enum NavigationEffect {
    case showSecurityPrompt
    case showNavigationSuccess
    case showSecurityError
    case showDismissalConfirmation
    case hapticFeedback
    
    func toEffect() -> Effect {
        switch self {
        case .showSecurityPrompt:
            return ToastEffect(message: "需要安全驗證", duration: 1.0)
        case .showNavigationSuccess:
            return ToastEffect(message: "驗證成功，正在跳轉", duration: 1.0)
        case .showSecurityError:
            return ToastEffect(message: "驗證失敗", duration: 2.0)
        case .showDismissalConfirmation:
            return ToastEffect(message: "已取消操作", duration: 1.0)
        case .hapticFeedback:
            return HapticEffect(type: .light)
        }
    }
}