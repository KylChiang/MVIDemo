import Foundation

enum AnnouncementsIntent {
    case fetchAnnouncements
    case fetchSuccess([Announcement])
    case fetchFailure(Error)
    case refreshAnnouncements
}