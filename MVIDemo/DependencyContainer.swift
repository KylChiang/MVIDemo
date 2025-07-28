import Foundation

class DependencyContainer {
    // MARK: - Repositories
    lazy var authRepository: AuthRepository = AuthRepositoryImpl()
    lazy var announcementRepository: AnnouncementRepository = AnnouncementRepositoryImpl()
    
    // MARK: - Use Cases
    lazy var loginUseCase = LoginUseCase(authRepository: authRepository)
    lazy var logoutUseCase = LogoutUseCase(authRepository: authRepository)
    lazy var getCurrentUserUseCase = GetCurrentUserUseCase(authRepository: authRepository)
    lazy var fetchAnnouncementsUseCase = FetchAnnouncementsUseCase(announcementRepository: announcementRepository)
    
    // MARK: - Reducers
    func makeLoginReducer() -> LoginReducer {
        return LoginReducer(loginUseCase: loginUseCase)
    }
    
    func makeHomeReducer() -> HomeReducer {
        return HomeReducer(getCurrentUserUseCase: getCurrentUserUseCase, logoutUseCase: logoutUseCase)
    }
    
    func makeAnnouncementsReducer() -> AnnouncementsReducer {
        return AnnouncementsReducer(fetchAnnouncementsUseCase: fetchAnnouncementsUseCase)
    }
}