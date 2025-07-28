import Foundation

class GetCurrentUserUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute() -> User? {
        return authRepository.getCurrentUser()
    }
}