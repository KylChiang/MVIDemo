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
    private let accountValidationUseCase: AccountValidationUseCase
    private let effectHandler: EffectHandler
    
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

