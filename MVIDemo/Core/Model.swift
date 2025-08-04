import Foundation
import Combine

protocol ModelProtocol: ObservableObject {
    associatedtype Intent
    associatedtype State
    
    var state: State { get }
    
    func handle(_ intent: Intent)
}

class LoginModel: ModelProtocol, ObservableObject {
    typealias Intent = LoginIntent
    typealias State = LoginState
    
    @Published private(set) var state = LoginState.initial
    
    private let reducer: LoginReducerProtocol
    private let loginUseCase: LoginUseCase
    private let effectHandler: EffectHandler
    
    init(
        reducer: LoginReducerProtocol,
        loginUseCase: LoginUseCase,
        effectHandler: EffectHandler
    ) {
        self.reducer = reducer
        self.loginUseCase = loginUseCase
        self.effectHandler = effectHandler
    }
    
    func handle(_ intent: LoginIntent) {
        switch intent {
        case .accountChanged, .clearError:
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
            
        case .loginSuccess, .loginFailure:
            state = reducer.reduce(state: state, intent: intent)
        }
    }
}

class HomeModel: ModelProtocol, ObservableObject {
    typealias Intent = HomeIntent
    typealias State = HomeState
    
    @Published private(set) var state = HomeState.initial
    
    private let reducer: HomeReducerProtocol
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let logoutUseCase: LogoutUseCase
    private let effectHandler: EffectHandler
    
    init(
        reducer: HomeReducerProtocol,
        getCurrentUserUseCase: GetCurrentUserUseCase,
        logoutUseCase: LogoutUseCase,
        effectHandler: EffectHandler
    ) {
        self.reducer = reducer
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.logoutUseCase = logoutUseCase
        self.effectHandler = effectHandler
    }
    
    func handle(_ intent: HomeIntent) {
        switch intent {
        case .viewAppeared:
            state = reducer.reduce(state: state, intent: intent)
            let user = getCurrentUserUseCase.execute()
            handle(.userLoaded(user))
            
        case .userLoaded, .clearNavigationFlag:
            state = reducer.reduce(state: state, intent: intent)
            
        case .logoutClicked:
            state = reducer.reduce(state: state, intent: intent)
            
            Task { @MainActor in
                do {
                    try await logoutUseCase.execute()
                    handle(.logoutSuccess)
                    effectHandler.handle(HomeEffect.showLogoutSuccess.toEffect())
                    effectHandler.handle(HomeEffect.navigateToLogin.toEffect())
                } catch {
                    handle(.logoutFailure(error))
                    effectHandler.handle(HomeEffect.showLogoutError(error.localizedDescription).toEffect())
                }
            }
            
        case .logoutSuccess, .logoutFailure:
            state = reducer.reduce(state: state, intent: intent)
            
        case .openAnnouncements:
            state = reducer.reduce(state: state, intent: intent)
            effectHandler.handle(HomeEffect.navigateToAnnouncements.toEffect())
        }
    }
}

class AnnouncementsModel: ModelProtocol, ObservableObject {
    typealias Intent = AnnouncementsIntent
    typealias State = AnnouncementsState
    
    @Published private(set) var state = AnnouncementsState.initial
    
    private let reducer: AnnouncementsReducerProtocol
    private let fetchAnnouncementsUseCase: FetchAnnouncementsUseCase
    private let effectHandler: EffectHandler
    
    init(
        reducer: AnnouncementsReducerProtocol,
        fetchAnnouncementsUseCase: FetchAnnouncementsUseCase,
        effectHandler: EffectHandler
    ) {
        self.reducer = reducer
        self.fetchAnnouncementsUseCase = fetchAnnouncementsUseCase
        self.effectHandler = effectHandler
    }
    
    func handle(_ intent: AnnouncementsIntent) {
        switch intent {
        case .fetchAnnouncements, .refreshAnnouncements:
            state = reducer.reduce(state: state, intent: intent)
            
            Task { @MainActor in
                do {
                    let announcements = try await fetchAnnouncementsUseCase.execute()
                    handle(.fetchSuccess(announcements))
                    if intent == .refreshAnnouncements {
                        effectHandler.handle(AnnouncementsEffect.refreshComplete.toEffect())
                    }
                } catch {
                    handle(.fetchFailure(error))
                    effectHandler.handle(AnnouncementsEffect.showFetchError(error.localizedDescription).toEffect())
                }
            }
            
        case .fetchSuccess:
            state = reducer.reduce(state: state, intent: intent)
            
        case .fetchFailure:
            state = reducer.reduce(state: state, intent: intent)
        }
    }
}

class EffectHandler {
    func handle(_ effect: Effect) {
        effect.execute()
    }
}