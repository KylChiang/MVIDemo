import Foundation

class AnnouncementsReducer: ObservableObject {
    @Published var state = AnnouncementsState.initial
    
    private let fetchAnnouncementsUseCase: FetchAnnouncementsUseCase
    
    init(fetchAnnouncementsUseCase: FetchAnnouncementsUseCase) {
        self.fetchAnnouncementsUseCase = fetchAnnouncementsUseCase
    }
    
    func handle(_ intent: AnnouncementsIntent) {
        switch intent {
        case .fetchAnnouncements, .refreshAnnouncements:
            state = AnnouncementsState(
                announcements: state.announcements,
                isLoading: true,
                errorMessage: nil
            )
            
            Task { @MainActor in
                do {
                    let announcements = try await fetchAnnouncementsUseCase.execute()
                    handle(.fetchSuccess(announcements))
                } catch {
                    handle(.fetchFailure(error))
                }
            }
            
        case .fetchSuccess(let announcements):
            state = AnnouncementsState(
                announcements: announcements,
                isLoading: false,
                errorMessage: nil
            )
            
        case .fetchFailure(let error):
            state = AnnouncementsState(
                announcements: state.announcements,
                isLoading: false,
                errorMessage: error.localizedDescription
            )
        }
    }
}