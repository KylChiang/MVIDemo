import Foundation

class AnnouncementRepositoryImpl: AnnouncementRepository {
    func fetchAnnouncements() async throws -> [Announcement] {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            throw AnnouncementError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let announcements = try JSONDecoder().decode([Announcement].self, from: data)
        return announcements
    }
}

enum AnnouncementError: Error, LocalizedError {
    case invalidURL
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無效的 URL"
        case .networkError:
            return "網路連線失敗"
        }
    }
}