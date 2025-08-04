//
//  HomeEffect.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/4.
//

import Foundation
import SwiftUI

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
