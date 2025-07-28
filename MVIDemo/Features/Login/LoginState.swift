import Foundation

struct LoginState: Equatable {
    let account: String
    let isLoading: Bool
    let isLoginEnabled: Bool
    let errorMessage: String?
    let user: User?
    
    init(
        account: String = "",
        isLoading: Bool = false,
        isLoginEnabled: Bool = false,
        errorMessage: String? = nil,
        user: User? = nil
    ) {
        self.account = account
        self.isLoading = isLoading
        self.isLoginEnabled = !account.isEmpty && !isLoading
        self.errorMessage = errorMessage
        self.user = user
    }
    
    static let initial = LoginState()
}