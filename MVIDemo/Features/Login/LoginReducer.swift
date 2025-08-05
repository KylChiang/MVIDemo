import Foundation

protocol LoginReducerProtocol {
    func reduce(state: LoginState, intent: LoginIntent) -> LoginState
}

struct LoginReducer: LoginReducerProtocol {
    func reduce(state: LoginState, intent: LoginIntent) -> LoginState {
        switch intent {
        case .accountChanged(let account):
            return LoginState(
                account: account,
                isLoading: state.isLoading,
                isLoginEnabled: !account.isEmpty && !state.isLoading,
                errorMessage: nil,
                user: state.user
            )
            
        case .loginClicked:
            return LoginState(
                account: state.account,
                isLoading: true,
                isLoginEnabled: false,
                errorMessage: nil,
                user: state.user
            )
            
        case .loginSuccess(let user):
            return LoginState(
                account: state.account,
                isLoading: false,
                isLoginEnabled: true,
                errorMessage: nil,
                user: user
            )
            
        case .loginFailure(let error):
            return LoginState(
                account: state.account,
                isLoading: false,
                isLoginEnabled: true,
                errorMessage: error.localizedDescription,
                user: nil
            )
            
        case .clearError:
            return LoginState(
                account: state.account,
                isLoading: state.isLoading,
                isLoginEnabled: state.isLoginEnabled,
                errorMessage: nil,
                user: state.user
            )
            
        case .accountValidationFailed(let message):
            return LoginState(
                account: state.account,
                isLoading: false,
                isLoginEnabled: false,
                errorMessage: message,
                user: state.user
            )
        }
    }
}