//
//  AnnouncementsModel.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/4.
//

import Foundation

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
