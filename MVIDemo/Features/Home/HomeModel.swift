//
//  HomeModel.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/4.
//

import Foundation

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
