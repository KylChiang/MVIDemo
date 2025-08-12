import Foundation

protocol HomeReducerProtocol {
    func reduce(state: HomeState, intent: HomeIntent) -> HomeState
}

struct HomeReducer: HomeReducerProtocol {
    func reduce(state: HomeState, intent: HomeIntent) -> HomeState {
        switch intent {
        case .userLoaded(let user):
            return HomeState(
                user: user,
                isLoading: false,
                errorMessage: nil,
                shouldNavigateToAnnouncements: false
            )
            
        case .logoutClicked:
            return HomeState(
                user: state.user,
                isLoading: true,
                errorMessage: nil,
                shouldNavigateToAnnouncements: false
            )
            
        case .logoutSuccess:
            return HomeState(
                user: nil,
                isLoading: false,
                errorMessage: nil,
                shouldNavigateToAnnouncements: false
            )
            
        case .logoutFailure(let error):
            return HomeState(
                user: state.user,
                isLoading: false,
                errorMessage: error.localizedDescription,
                shouldNavigateToAnnouncements: false
            )
            
        case .openAnnouncements:
            return HomeState(
                user: state.user,
                isLoading: state.isLoading,
                errorMessage: state.errorMessage,
                shouldNavigateToAnnouncements: true
            )
            
        case .viewAppeared:
            return HomeState(
                user: state.user,
                isLoading: true,
                errorMessage: nil,
                shouldNavigateToAnnouncements: false
            )
            
        case .clearNavigationFlag:
            return HomeState(
                user: state.user,
                isLoading: state.isLoading,
                errorMessage: state.errorMessage,
                shouldNavigateToAnnouncements: false
            )
        }
    }
}