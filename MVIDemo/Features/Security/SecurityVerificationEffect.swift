//
//  SecurityVerificationEffect.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/13.
//

import Foundation

enum SecurityVerificationEffect {
    case showVerificationSuccess
    case showVerificationError(String)
    case hapticFeedback
    
    func toEffect() -> Effect {
        switch self {
        case .showVerificationSuccess:
            return ToastEffect(message: "驗證成功", duration: 1.5)
        case .showVerificationError(let message):
            return AlertEffect(title: "驗證失敗", message: message, actions: [
                AlertAction(title: "確定", style: .default)
            ])
        case .hapticFeedback:
            return HapticEffect(type: .light)
        }
    }
}