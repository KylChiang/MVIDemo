import Foundation

class LoginReducer: ObservableObject {
    @Published var state = LoginState.initial
    
    private let loginUseCase: LoginUseCase
    
    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }
    
    func handle(_ intent: LoginIntent) {
        switch intent {
        case .accountChanged(let account):
            state = LoginState(
                account: account,
                isLoading: state.isLoading,
                isLoginEnabled: !account.isEmpty,
                errorMessage: nil,
                user: state.user
            )
            
        case .loginClicked:
            guard !state.account.isEmpty else { return }
            
            state = LoginState(
                account: state.account,
                isLoading: true,
                isLoginEnabled: false,
                errorMessage: nil,
                user: state.user
            )
            
            Task { @MainActor in
                do {
                    let user = try await loginUseCase.execute(account: state.account)
                    handle(.loginSuccess(user))
                } catch {
                    handle(.loginFailure(error))
                }
            }
            
        case .loginSuccess(let user):
            state = LoginState(
                account: state.account,
                isLoading: false,
                isLoginEnabled: true,
                errorMessage: nil,
                user: user
            )
            
        case .loginFailure(let error):
            state = LoginState(
                account: state.account,
                isLoading: false,
                isLoginEnabled: true,
                errorMessage: error.localizedDescription,
                user: nil
            )
        }
    }
}