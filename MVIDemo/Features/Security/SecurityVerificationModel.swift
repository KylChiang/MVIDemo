//
//  SecurityVerificationModel.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/13.
//

import Foundation

// MARK: - Security Verification Intent
enum SecurityVerificationIntent {
    case verifyPassword(String)
    case verificationSuccess
    case verificationFailure(Error)
    case clearError
}

// MARK: - Security Verification State
struct SecurityVerificationState: Equatable {
    let isLoading: Bool
    let isVerificationSuccess: Bool
    let errorMessage: String?
    
    static let initial = SecurityVerificationState(
        isLoading: false,
        isVerificationSuccess: false,
        errorMessage: nil
    )
}

// MARK: - Security Verification Reducer
protocol SecurityVerificationReducerProtocol {
    func reduce(state: SecurityVerificationState, intent: SecurityVerificationIntent) -> SecurityVerificationState
}

class SecurityVerificationReducer: SecurityVerificationReducerProtocol {
    func reduce(state: SecurityVerificationState, intent: SecurityVerificationIntent) -> SecurityVerificationState {
        switch intent {
        case .verifyPassword:
            return SecurityVerificationState(
                isLoading: true,
                isVerificationSuccess: false,
                errorMessage: nil
            )
            
        case .verificationSuccess:
            return SecurityVerificationState(
                isLoading: false,
                isVerificationSuccess: true,
                errorMessage: nil
            )
            
        case .verificationFailure(let error):
            return SecurityVerificationState(
                isLoading: false,
                isVerificationSuccess: false,
                errorMessage: error.localizedDescription
            )
            
        case .clearError:
            return SecurityVerificationState(
                isLoading: state.isLoading,
                isVerificationSuccess: state.isVerificationSuccess,
                errorMessage: nil
            )
        }
    }
}

// MARK: - Security Verification Model
class SecurityVerificationModel: ModelProtocol, ObservableObject {
    typealias Intent = SecurityVerificationIntent
    typealias State = SecurityVerificationState
    
    @Published private(set) var state = SecurityVerificationState.initial
    
    private let reducer: SecurityVerificationReducerProtocol
    private let securityVerificationUseCase: SecurityVerificationUseCase
    private let effectHandler: EffectHandler
    
    init(
        reducer: SecurityVerificationReducerProtocol,
        securityVerificationUseCase: SecurityVerificationUseCase,
        effectHandler: EffectHandler
    ) {
        self.reducer = reducer
        self.securityVerificationUseCase = securityVerificationUseCase
        self.effectHandler = effectHandler
    }
    
    func handle(_ intent: SecurityVerificationIntent) {
        switch intent {
        case .verifyPassword(let password):
            state = reducer.reduce(state: state, intent: intent)
            
            Task { @MainActor in
                do {
                    let isValid = try await securityVerificationUseCase.verifyPassword(password)
                    if isValid {
                        handle(.verificationSuccess)
                        effectHandler.handle(SecurityVerificationEffect.showVerificationSuccess.toEffect())
                        effectHandler.handle(SecurityVerificationEffect.hapticFeedback.toEffect())
                    } else {
                        let error = SecurityVerificationError.invalidPassword
                        handle(.verificationFailure(error))
                        effectHandler.handle(SecurityVerificationEffect.showVerificationError(error.localizedDescription).toEffect())
                    }
                } catch {
                    handle(.verificationFailure(error))
                    effectHandler.handle(SecurityVerificationEffect.showVerificationError(error.localizedDescription).toEffect())
                }
            }
            
        case .verificationSuccess, .verificationFailure, .clearError:
            state = reducer.reduce(state: state, intent: intent)
        }
    }
}

// MARK: - Security Verification Error
enum SecurityVerificationError: LocalizedError {
    case invalidPassword
    case networkError
    case systemError
    
    var errorDescription: String? {
        switch self {
        case .invalidPassword:
            return "密碼錯誤，請重新輸入"
        case .networkError:
            return "網路連線錯誤，請稍後再試"
        case .systemError:
            return "系統錯誤，請稍後再試"
        }
    }
}