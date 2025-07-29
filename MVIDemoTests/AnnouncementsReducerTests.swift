import XCTest
@testable import MVIDemo

final class AnnouncementsReducerTests: XCTestCase {
    var mockFetchAnnouncementsUseCase: MockFetchAnnouncementsUseCase!
    var announcementsReducer: AnnouncementsReducer!
    
    override func setUp() {
        super.setUp()
        mockFetchAnnouncementsUseCase = MockFetchAnnouncementsUseCase()
        announcementsReducer = AnnouncementsReducer(fetchAnnouncementsUseCase: mockFetchAnnouncementsUseCase)
    }
    
    override func tearDown() {
        mockFetchAnnouncementsUseCase = nil
        announcementsReducer = nil
        super.tearDown()
    }
    
    func testFetchAnnouncements() {
        // Given
        let existingAnnouncements = [
            Announcement(userId: 1, id: 1, title: "Existing", body: "Existing body")
        ]
        announcementsReducer.state = AnnouncementsState(announcements: existingAnnouncements)
        mockFetchAnnouncementsUseCase.shouldSucceed = true
        
        // When
        announcementsReducer.handle(.fetchAnnouncements)
        
        // Then
        XCTAssertEqual(announcementsReducer.state.announcements, existingAnnouncements)
        XCTAssertTrue(announcementsReducer.state.isLoading)
        XCTAssertNil(announcementsReducer.state.errorMessage)
    }
    
    func testRefreshAnnouncements() {
        // Given
        let existingAnnouncements = [
            Announcement(userId: 1, id: 1, title: "Existing", body: "Existing body")
        ]
        announcementsReducer.state = AnnouncementsState(announcements: existingAnnouncements)
        mockFetchAnnouncementsUseCase.shouldSucceed = true
        
        // When
        announcementsReducer.handle(.refreshAnnouncements)
        
        // Then
        XCTAssertEqual(announcementsReducer.state.announcements, existingAnnouncements)
        XCTAssertTrue(announcementsReducer.state.isLoading)
        XCTAssertNil(announcementsReducer.state.errorMessage)
    }
    
    func testFetchSuccess() {
        // Given
        let mockAnnouncements = [
            Announcement(userId: 1, id: 1, title: "Test Announcement 1", body: "Test body 1"),
            Announcement(userId: 2, id: 2, title: "Test Announcement 2", body: "Test body 2")
        ]
        announcementsReducer.state = AnnouncementsState(isLoading: true)
        
        // When
        announcementsReducer.handle(.fetchSuccess(mockAnnouncements))
        
        // Then
        XCTAssertEqual(announcementsReducer.state.announcements, mockAnnouncements)
        XCTAssertFalse(announcementsReducer.state.isLoading)
        XCTAssertNil(announcementsReducer.state.errorMessage)
    }
    
    func testFetchFailure() {
        // Given
        let existingAnnouncements = [
            Announcement(userId: 1, id: 1, title: "Existing", body: "Existing body")
        ]
        announcementsReducer.state = AnnouncementsState(announcements: existingAnnouncements, isLoading: true)
        let error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        
        // When
        announcementsReducer.handle(.fetchFailure(error))
        
        // Then
        XCTAssertEqual(announcementsReducer.state.announcements, existingAnnouncements)
        XCTAssertFalse(announcementsReducer.state.isLoading)
        XCTAssertEqual(announcementsReducer.state.errorMessage, "Network error")
    }
    
    func testInitialState() {
        // Then
        XCTAssertTrue(announcementsReducer.state.announcements.isEmpty)
        XCTAssertFalse(announcementsReducer.state.isLoading)
        XCTAssertNil(announcementsReducer.state.errorMessage)
    }
}

// MARK: - Mock Classes
class MockFetchAnnouncementsUseCase: FetchAnnouncementsUseCase {
    var shouldSucceed = true
    var mockAnnouncements: [Announcement] = []
    var fetchCalled = false
    
    init() {
        super.init(announcementRepository: MockAnnouncementRepository())
    }
    
    override func execute() async throws -> [Announcement] {
        fetchCalled = true
        if shouldSucceed {
            return mockAnnouncements
        } else {
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock fetch error"])
        }
    }
}

class MockAnnouncementRepository: AnnouncementRepository {
    var shouldSucceed = true
    var mockAnnouncements: [Announcement] = []
    
    func fetchAnnouncements() async throws -> [Announcement] {
        if shouldSucceed {
            return mockAnnouncements
        } else {
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock repository error"])
        }
    }
}