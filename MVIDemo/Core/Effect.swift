import Foundation
import SwiftUI

protocol Effect {
    func execute()
}

struct NavigationEffect: Effect {
    let destination: AnyView
    let navigationController: UINavigationController?
    
    func execute() {
        // Handle navigation logic
    }
}

struct AlertEffect: Effect {
    let title: String
    let message: String
    let actions: [AlertAction]
    
    func execute() {
        // Handle alert presentation
    }
}

struct ToastEffect: Effect {
    let message: String
    let duration: TimeInterval
    
    func execute() {
        // Handle toast notification
    }
}

struct HapticEffect: Effect {
    let type: UIImpactFeedbackGenerator.FeedbackStyle
    
    func execute() {
        let generator = UIImpactFeedbackGenerator(style: type)
        generator.impactOccurred()
    }
}

struct AlertAction {
    let title: String
    let style: UIAlertAction.Style
    let handler: (() -> Void)?
    
    init(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

enum LoginEffect {
    case showLoginSuccess
    case showLoginError(String)
    case navigateToHome
    case hapticFeedback
    
    func toEffect() -> Effect {
        switch self {
        case .showLoginSuccess:
            return ToastEffect(message: "登入成功", duration: 2.0)
        case .showLoginError(let message):
            return AlertEffect(title: "登入失敗", message: message, actions: [
                AlertAction(title: "確定", style: .default)
            ])
        case .navigateToHome:
            return NavigationEffect(destination: AnyView(EmptyView()), navigationController: nil)
        case .hapticFeedback:
            return HapticEffect(type: .light)
        }
    }
}

enum HomeEffect {
    case showLogoutSuccess
    case showLogoutError(String)
    case navigateToLogin
    case navigateToAnnouncements
    case hapticFeedback
    
    func toEffect() -> Effect {
        switch self {
        case .showLogoutSuccess:
            return ToastEffect(message: "登出成功", duration: 2.0)
        case .showLogoutError(let message):
            return AlertEffect(title: "登出失敗", message: message, actions: [
                AlertAction(title: "確定", style: .default)
            ])
        case .navigateToLogin:
            return NavigationEffect(destination: AnyView(EmptyView()), navigationController: nil)
        case .navigateToAnnouncements:
            return NavigationEffect(destination: AnyView(EmptyView()), navigationController: nil)
        case .hapticFeedback:
            return HapticEffect(type: .light)
        }
    }
}

enum AnnouncementsEffect {
    case showFetchSuccess
    case showFetchError(String)
    case hapticFeedback
    case refreshComplete
    
    func toEffect() -> Effect {
        switch self {
        case .showFetchSuccess:
            return ToastEffect(message: "公告載入成功", duration: 1.5)
        case .showFetchError(let message):
            return AlertEffect(title: "載入失敗", message: message, actions: [
                AlertAction(title: "重試", style: .default),
                AlertAction(title: "取消", style: .cancel)
            ])
        case .hapticFeedback:
            return HapticEffect(type: .light)
        case .refreshComplete:
            return HapticEffect(type: .medium)
        }
    }
}