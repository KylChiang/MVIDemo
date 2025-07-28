import Foundation

class LogoutUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute() async throws {
        try await authRepository.logout()
        authRepository.clearUser()
    }
}