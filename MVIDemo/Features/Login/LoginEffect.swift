//
//  LoginEffect.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/4.
//

import Foundation
import SwiftUI

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
