import Foundation

class LoginUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute(account: String) async throws -> User {
        guard !account.isEmpty else {
            throw LoginError.emptyAccount
        }
        
        let user = try await authRepository.login(account: account)
        authRepository.saveUser(user)
        return user
    }
}

enum LoginError: Error, LocalizedError {
    case emptyAccount
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .emptyAccount:
            return "帳號不能為空"
        case .networkError:
            return "網路連線失敗"
        }
    }
}