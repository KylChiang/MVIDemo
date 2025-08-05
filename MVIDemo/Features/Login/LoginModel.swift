//
//  LoginModel.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/4.
//

import Foundation

class LoginModel: ModelProtocol, ObservableObject {
    typealias Intent = LoginIntent
    typealias State = LoginState
    
    @Published private(set) var state = LoginState.initial
    
    private let reducer: LoginReducerProtocol
    private let loginUseCase: LoginUseCase
    private let effectHandler: EffectHandler
    
    init(
        reducer: LoginReducerProtocol,
        loginUseCase: LoginUseCase,
        effectHandler: EffectHandler
    ) {
        self.reducer = reducer
        self.loginUseCase = loginUseCase
        self.effectHandler = effectHandler
    }
    
    func handle(_ intent: LoginIntent) {
        switch intent {
        case .accountChanged(let account):
            if account.count > 10 {
                handle(.accountValidationFailed("帳號最多只能輸入10個字"))
            } else {
                state = reducer.reduce(state: state, intent: intent)
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
                    effectHandler.handle(LoginEffect.showLoginSuccess.toEffect())
                    effectHandler.handle(LoginEffect.hapticFeedback.toEffect())
                    effectHandler.handle(LoginEffect.navigateToHome.toEffect())
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

