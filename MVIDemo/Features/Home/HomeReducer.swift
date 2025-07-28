import Foundation

class HomeReducer: ObservableObject {
    @Published var state = HomeState.initial
    
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let logoutUseCase: LogoutUseCase
    
    init(getCurrentUserUseCase: GetCurrentUserUseCase, logoutUseCase: LogoutUseCase) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.logoutUseCase = logoutUseCase
    }
    
    func handle(_ intent: HomeIntent) {
        switch intent {
        case .viewAppeared:
            let user = getCurrentUserUseCase.execute()
            state = HomeState(
                user: user,
                isLoading: false,
                errorMessage: nil,
                shouldNavigateToAnnouncements: false
            )
            
        case .logoutClicked:
            state = HomeState(
                user: state.user,
                isLoading: true,
                errorMessage: nil,
                shouldNavigateToAnnouncements: false
            )
            
            Task { @MainActor in
                do {
                    try await logoutUseCase.execute()
                    handle(.logoutSuccess)
                } catch {
                    handle(.logoutFailure(error))
                }
            }
            
        case .logoutSuccess:
            state = HomeState(
                user: nil,
                isLoading: false,
                errorMessage: nil,
                shouldNavigateToAnnouncements: false
            )
            
        case .logoutFailure(let error):
            state = HomeState(
                user: state.user,
                isLoading: false,
                errorMessage: error.localizedDescription,
                shouldNavigateToAnnouncements: false
            )
            
        case .openAnnouncements:
            state = HomeState(
                user: state.user,
                isLoading: state.isLoading,
                errorMessage: state.errorMessage,
                shouldNavigateToAnnouncements: true
            )
        }
    }
}