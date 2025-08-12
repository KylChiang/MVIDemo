import XCTest
@testable import MVIDemo

final class AnnouncementsReducerTests: XCTestCase {
    var announcementsReducer: AnnouncementsReducer!
    
    override func setUp() {
        super.setUp()
        announcementsReducer = AnnouncementsReducer()
    }
    
    override func tearDown() {
        announcementsReducer = nil
        super.tearDown()
    }
    
    func testFetchAnnouncements() {
        // Given
        let existingAnnouncements = [
            Announcement(userId: 1, id: 1, title: "Existing", body: "Existing body")
        ]
        let initialState = AnnouncementsState(announcements: existingAnnouncements)
        
        // When
        let newState = announcementsReducer.reduce(state: initialState, intent: .fetchAnnouncements)
        
        // Then
        XCTAssertEqual(newState.announcements, existingAnnouncements)
        XCTAssertTrue(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
    }
    
    func testRefreshAnnouncements() {
        // Given
        let existingAnnouncements = [
            Announcement(userId: 1, id: 1, title: "Existing", body: "Existing body")
        ]
        let initialState = AnnouncementsState(announcements: existingAnnouncements)
        
        // When
        let newState = announcementsReducer.reduce(state: initialState, intent: .refreshAnnouncements)
        
        // Then
        XCTAssertEqual(newState.announcements, existingAnnouncements)
        XCTAssertTrue(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
    }
    
    func testFetchSuccess() {
        // Given
        let mockAnnouncements = [
            Announcement(userId: 1, id: 1, title: "Test Announcement 1", body: "Test body 1"),
            Announcement(userId: 2, id: 2, title: "Test Announcement 2", body: "Test body 2")
        ]
        let initialState = AnnouncementsState(isLoading: true)
        
        // When
        let newState = announcementsReducer.reduce(state: initialState, intent: .fetchSuccess(mockAnnouncements))
        
        // Then
        XCTAssertEqual(newState.announcements, mockAnnouncements)
        XCTAssertFalse(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
    }
    
    func testFetchFailure() {
        // Given
        let existingAnnouncements = [
            Announcement(userId: 1, id: 1, title: "Existing", body: "Existing body")
        ]
        let initialState = AnnouncementsState(announcements: existingAnnouncements, isLoading: true)
        let error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        
        // When
        let newState = announcementsReducer.reduce(state: initialState, intent: .fetchFailure(error))
        
        // Then
        XCTAssertEqual(newState.announcements, existingAnnouncements)
        XCTAssertFalse(newState.isLoading)
        XCTAssertEqual(newState.errorMessage, "Network error")
    }
    
    func testInitialState() {
        // Given
        let initialState = AnnouncementsState.initial
        
        // Then
        XCTAssertTrue(initialState.announcements.isEmpty)
        XCTAssertFalse(initialState.isLoading)
        XCTAssertNil(initialState.errorMessage)
    }
}