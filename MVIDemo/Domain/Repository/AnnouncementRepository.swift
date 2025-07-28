import Foundation

protocol AnnouncementRepository {
    func fetchAnnouncements() async throws -> [Announcement]
}