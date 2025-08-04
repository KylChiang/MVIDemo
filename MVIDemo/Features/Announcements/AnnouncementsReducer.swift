import Foundation

protocol AnnouncementsReducerProtocol {
    func reduce(state: AnnouncementsState, intent: AnnouncementsIntent) -> AnnouncementsState
}

struct AnnouncementsReducer: AnnouncementsReducerProtocol {
    func reduce(state: AnnouncementsState, intent: AnnouncementsIntent) -> AnnouncementsState {
        switch intent {
        case .fetchAnnouncements, .refreshAnnouncements:
            return AnnouncementsState(
                announcements: state.announcements,
                isLoading: true,
                errorMessage: nil
            )
            
        case .fetchSuccess(let announcements):
            return AnnouncementsState(
                announcements: announcements,
                isLoading: false,
                errorMessage: nil
            )
            
        case .fetchFailure(let error):
            return AnnouncementsState(
                announcements: state.announcements,
                isLoading: false,
                errorMessage: error.localizedDescription
            )
        }
    }
}