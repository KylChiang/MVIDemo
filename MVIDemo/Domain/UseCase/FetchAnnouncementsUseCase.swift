import Foundation

class FetchAnnouncementsUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute() async throws -> [Announcement] {
        return try await announcementRepository.fetchAnnouncements()
    }
}