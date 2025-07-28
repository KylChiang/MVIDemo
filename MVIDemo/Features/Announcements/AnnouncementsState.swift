import Foundation

struct AnnouncementsState: Equatable {
    let announcements: [Announcement]
    let isLoading: Bool
    let errorMessage: String?
    
    init(
        announcements: [Announcement] = [],
        isLoading: Bool = false,
        errorMessage: String? = nil
    ) {
        self.announcements = announcements
        self.isLoading = isLoading
        self.errorMessage = errorMessage
    }
    
    static let initial = AnnouncementsState()
}