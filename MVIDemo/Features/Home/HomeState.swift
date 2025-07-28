import Foundation

struct HomeState: Equatable {
    let user: User?
    let isLoading: Bool
    let errorMessage: String?
    let shouldNavigateToAnnouncements: Bool
    
    init(
        user: User? = nil,
        isLoading: Bool = false,
        errorMessage: String? = nil,
        shouldNavigateToAnnouncements: Bool = false
    ) {
        self.user = user
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.shouldNavigateToAnnouncements = shouldNavigateToAnnouncements
    }
    
    static let initial = HomeState()
}