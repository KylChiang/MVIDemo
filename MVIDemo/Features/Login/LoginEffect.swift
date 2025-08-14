//
//  LoginEffect.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/4.
//

/*
 
 Coordinator → Effect
 ** 將 Coordinator 的導航、彈窗邏輯轉為 Effect

   // 舊: Coordinator 處理導航
   class LoginCoordinator {
       func navigateToHome() { /* 導航邏輯 */ }
       func showAlert() { /* 顯示提示 */ }
   }

   // 新: Effect 處理子動作（side effect）
   enum LoginEffect {
       case navigateToHome
       case showLoginError(String)
       case hapticFeedback
   }
 
 */

import Foundation
import SwiftUI

enum LoginEffect {
    case showLoginSuccessToast
    case showLoginError(String)
    case showValidationError(String)
    case hapticFeedback
    
    func toEffect() -> Effect {
        switch self {
        case .showLoginSuccessToast:
            return ToastEffect(message: "登入成功", duration: 2.0)
        case .showLoginError(let message):
            return AlertEffect(title: "登入失敗", message: message, actions: [
                AlertAction(title: "確定", style: .default)
            ])
        case .showValidationError(let message):
            return ToastEffect(message: message, duration: 2.0)
        case .hapticFeedback:
            return HapticEffect(type: .light)
        }
    }
}
