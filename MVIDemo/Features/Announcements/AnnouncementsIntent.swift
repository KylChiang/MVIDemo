import Foundation

enum AnnouncementsIntent: Equatable {
    case fetchAnnouncements
    case fetchSuccess([Announcement])
    case fetchFailure(Error)
    case refreshAnnouncements
    
    static func == (lhs: AnnouncementsIntent, rhs: AnnouncementsIntent) -> Bool {
        switch (lhs, rhs) {
        case (.fetchAnnouncements, .fetchAnnouncements):
            return true
        case (.fetchSuccess(let lhsAnnouncements), .fetchSuccess(let rhsAnnouncements)):
            return lhsAnnouncements == rhsAnnouncements
        case (.fetchFailure(let lhsError), .fetchFailure(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.refreshAnnouncements, .refreshAnnouncements):
            return true
        default:
            return false
        }
    }
}