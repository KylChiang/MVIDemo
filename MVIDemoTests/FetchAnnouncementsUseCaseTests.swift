import XCTest
@testable import MVIDemo

final class FetchAnnouncementsUseCaseTests: XCTestCase {
    var mockAnnouncementRepository: MockAnnouncementRepository!
    var fetchAnnouncementsUseCase: FetchAnnouncementsUseCase!
    
    override func setUp() {
        super.setUp()
        mockAnnouncementRepository = MockAnnouncementRepository()
        fetchAnnouncementsUseCase = FetchAnnouncementsUseCase(announcementRepository: mockAnnouncementRepository)
    }
    
    override func tearDown() {
        mockAnnouncementRepository = nil
        fetchAnnouncementsUseCase = nil
        super.tearDown()
    }
    
    func testFetchAnnouncementsSuccess() async throws {
        // Given
        let mockAnnouncements = [
            Announcement(userId: 1, id: 1, title: "Test Title 1", body: "Test Body 1"),
            Announcement(userId: 2, id: 2, title: "Test Title 2", body: "Test Body 2")
        ]
        mockAnnouncementRepository.shouldSucceed = true
        mockAnnouncementRepository.mockAnnouncements = mockAnnouncements
        
        // When
        let result = try await fetchAnnouncementsUseCase.execute()
        
        // Then
        XCTAssertEqual(result, mockAnnouncements)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].title, "Test Title 1")
        XCTAssertEqual(result[1].title, "Test Title 2")
    }
    
    func testFetchAnnouncementsFailure() async {
        // Given
        mockAnnouncementRepository.shouldSucceed = false
        
        // When & Then
        do {
            _ = try await fetchAnnouncementsUseCase.execute()
            XCTFail("Expected fetchAnnouncements to throw an error")
        } catch {
            XCTAssertTrue(error is NSError)
            XCTAssertEqual((error as NSError).localizedDescription, "Mock repository error")
        }
    }
    
    func testFetchEmptyAnnouncements() async throws {
        // Given
        mockAnnouncementRepository.shouldSucceed = true
        mockAnnouncementRepository.mockAnnouncements = []
        
        // When
        let result = try await fetchAnnouncementsUseCase.execute()
        
        // Then
        XCTAssertTrue(result.isEmpty)
    }
}