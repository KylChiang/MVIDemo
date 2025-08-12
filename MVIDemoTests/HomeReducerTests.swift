import XCTest
@testable import MVIDemo

final class HomeReducerTests: XCTestCase {
    var homeReducer: HomeReducer!
    
    override func setUp() {
        super.setUp()
        homeReducer = HomeReducer()
    }
    
    override func tearDown() {
        homeReducer = nil
        super.tearDown()
    }
    
    func testViewAppeared() {
        // Given
        let initialState = HomeState.initial
        
        // When
        let newState = homeReducer.reduce(state: initialState, intent: .viewAppeared)
        
        // Then
        XCTAssertNil(newState.user)
        XCTAssertTrue(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
        XCTAssertFalse(newState.shouldNavigateToAnnouncements)
    }
    
    func testUserLoaded() {
        // Given
        let initialState = HomeState(isLoading: true)
        let mockUser = User(account: "testUser", token: "testToken")
        
        // When
        let newState = homeReducer.reduce(state: initialState, intent: .userLoaded(mockUser))
        
        // Then
        XCTAssertEqual(newState.user, mockUser)
        XCTAssertFalse(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
        XCTAssertFalse(newState.shouldNavigateToAnnouncements)
    }
    
    func testUserLoadedWithNoUser() {
        // Given
        let initialState = HomeState(isLoading: true)
        
        // When
        let newState = homeReducer.reduce(state: initialState, intent: .userLoaded(nil))
        
        // Then
        XCTAssertNil(newState.user)
        XCTAssertFalse(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
        XCTAssertFalse(newState.shouldNavigateToAnnouncements)
    }
    
    func testLogoutClicked() {
        // Given
        let mockUser = User(account: "testUser", token: "testToken")
        let initialState = HomeState(user: mockUser)
        
        // When
        let newState = homeReducer.reduce(state: initialState, intent: .logoutClicked)
        
        // Then
        XCTAssertEqual(newState.user, mockUser)
        XCTAssertTrue(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
        XCTAssertFalse(newState.shouldNavigateToAnnouncements)
    }
    
    func testLogoutSuccess() {
        // Given
        let mockUser = User(account: "testUser", token: "testToken")
        let initialState = HomeState(user: mockUser, isLoading: true)
        
        // When
        let newState = homeReducer.reduce(state: initialState, intent: .logoutSuccess)
        
        // Then
        XCTAssertNil(newState.user)
        XCTAssertFalse(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
        XCTAssertFalse(newState.shouldNavigateToAnnouncements)
    }
    
    func testLogoutFailure() {
        // Given
        let mockUser = User(account: "testUser", token: "testToken")
        let initialState = HomeState(user: mockUser, isLoading: true)
        let error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Logout failed"])
        
        // When
        let newState = homeReducer.reduce(state: initialState, intent: .logoutFailure(error))
        
        // Then
        XCTAssertEqual(newState.user, mockUser)
        XCTAssertFalse(newState.isLoading)
        XCTAssertEqual(newState.errorMessage, "Logout failed")
        XCTAssertFalse(newState.shouldNavigateToAnnouncements)
    }
    
    func testOpenAnnouncements() {
        // Given
        let mockUser = User(account: "testUser", token: "testToken")
        let initialState = HomeState(user: mockUser)
        
        // When
        let newState = homeReducer.reduce(state: initialState, intent: .openAnnouncements)
        
        // Then
        XCTAssertEqual(newState.user, mockUser)
        XCTAssertFalse(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
        XCTAssertTrue(newState.shouldNavigateToAnnouncements)
    }
    
    func testClearNavigationFlag() {
        // Given
        let mockUser = User(account: "testUser", token: "testToken")
        let initialState = HomeState(user: mockUser, shouldNavigateToAnnouncements: true)
        
        // When
        let newState = homeReducer.reduce(state: initialState, intent: .clearNavigationFlag)
        
        // Then
        XCTAssertEqual(newState.user, mockUser)
        XCTAssertFalse(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
        XCTAssertFalse(newState.shouldNavigateToAnnouncements)
    }
}