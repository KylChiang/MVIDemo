//
//  LoginModel.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/4.
//

/*
 
 Presenter → Model

   // 舊 MVP: Presenter 處理 UI 邏輯
   class LoginPresenter {
       func login(account: String) { /* 處理登入邏輯 */ }
   }

   // 新 MVI: Model 處理 Intent
   class LoginModel: ModelProtocol {
       func handle(_ intent: LoginIntent) { /* 統一處理所有意圖 */ }
   }
 
 */

import Foundation

class LoginModel: ModelProtocol, ObservableObject {
    typealias Intent = LoginIntent
    typealias State = LoginState
    
    @Published private(set) var state = LoginState.initial
    
    private let reducer: LoginReducerProtocol
    private let loginUseCase: LoginUseCase
    private let accountValidationUseCase: AccountValidationUseCase
    private let effectHandler: EffectHandler
    
    // 導航回調
    var onLoginSuccess: (() -> Void)?
    
    init(
        reducer: LoginReducerProtocol,
        loginUseCase: LoginUseCase,
        accountValidationUseCase: AccountValidationUseCase,
        effectHandler: EffectHandler
    ) {
        self.reducer = reducer
        self.loginUseCase = loginUseCase
        self.accountValidationUseCase = accountValidationUseCase
        self.effectHandler = effectHandler
    }
    
    func handle(_ intent: LoginIntent) {
        switch intent {
        case .accountChanged(let account):
            let validationResult = accountValidationUseCase.validate(account)
            
            switch validationResult {
            case .valid(let validAccount):
                state = reducer.reduce(state: state, intent: .accountChanged(validAccount))
                
            case .invalid(let truncatedAccount, let message):
                state = reducer.reduce(state: state, intent: .accountChanged(truncatedAccount))
                handle(.accountValidationFailed(message))
            }
            
        case .clearError:
            state = reducer.reduce(state: state, intent: intent)
            
        case .loginClicked:
            guard !state.account.isEmpty else { return }
            
            state = reducer.reduce(state: state, intent: intent)
            
            Task { @MainActor in
                do {
                    let user = try await loginUseCase.execute(account: state.account)
                    handle(.loginSuccess(user))
                    effectHandler.handle(LoginEffect.showLoginSuccessToast.toEffect())
                    effectHandler.handle(LoginEffect.hapticFeedback.toEffect())
                    
                    // 通過回調通知導航變更
                    onLoginSuccess?()
                } catch {
                    handle(.loginFailure(error))
                    effectHandler.handle(LoginEffect.showLoginError(error.localizedDescription).toEffect())
                }
            }
            
        case .loginSuccess, .loginFailure, .accountValidationFailed:
            state = reducer.reduce(state: state, intent: intent)
        }
    }
}

