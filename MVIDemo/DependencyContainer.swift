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
    lazy var accountValidationUseCase: AccountValidationUseCase = AccountValidationUseCaseImpl()
    lazy var securityVerificationUseCase: SecurityVerificationUseCase = SecurityVerificationUseCaseImpl()
    
    // MARK: - Core Components
    lazy var effectHandler = EffectHandler()
    
    // MARK: - Reducers
    func makeLoginReducer() -> LoginReducer {
        return LoginReducer()
    }
    
    func makeHomeReducer() -> HomeReducer {
        return HomeReducer()
    }
    
    func makeAnnouncementsReducer() -> AnnouncementsReducer {
        return AnnouncementsReducer()
    }
    
    func makeNavigationReducer() -> NavigationReducer {
        return NavigationReducer()
    }
    
    func makeSecurityVerificationReducer() -> SecurityVerificationReducer {
        return SecurityVerificationReducer()
    }
    
    // MARK: - Models
    func makeLoginModel() -> LoginModel {
        return LoginModel(
            reducer: makeLoginReducer(),
            loginUseCase: loginUseCase,
            accountValidationUseCase: accountValidationUseCase,
            effectHandler: effectHandler
        )
    }
    
    func makeHomeModel() -> HomeModel {
        return HomeModel(
            reducer: makeHomeReducer(),
            getCurrentUserUseCase: getCurrentUserUseCase,
            logoutUseCase: logoutUseCase,
            effectHandler: effectHandler
        )
    }
    
    func makeAnnouncementsModel() -> AnnouncementsModel {
        return AnnouncementsModel(
            reducer: makeAnnouncementsReducer(),
            fetchAnnouncementsUseCase: fetchAnnouncementsUseCase,
            effectHandler: effectHandler
        )
    }
    
    func makeNavigationManager() -> NavigationManager {
        return NavigationManager(
            reducer: makeNavigationReducer(),
            effectHandler: effectHandler
        )
    }
    
    func makeSecurityVerificationModel() -> SecurityVerificationModel {
        return SecurityVerificationModel(
            reducer: makeSecurityVerificationReducer(),
            securityVerificationUseCase: securityVerificationUseCase,
            effectHandler: effectHandler
        )
    }
}