import XCTest
@testable import MVIDemo

final class HomeReducerTests: XCTestCase {
    var mockGetCurrentUserUseCase: MockGetCurrentUserUseCase!
    var mockLogoutUseCase: MockLogoutUseCase!
    var homeReducer: HomeReducer!
    
    override func setUp() {
        super.setUp()
        mockGetCurrentUserUseCase = MockGetCurrentUserUseCase()
        mockLogoutUseCase = MockLogoutUseCase()
        homeReducer = HomeReducer(
            getCurrentUserUseCase: mockGetCurrentUserUseCase,
            logoutUseCase: mockLogoutUseCase
        )
    }
    
    override func tearDown() {
        mockGetCurrentUserUseCase = nil
        mockLogoutUseCase = nil
        homeReducer = nil
        super.tearDown()
    }
    
    func testViewAppeared() {
        // Given
        let mockUser = User(account: "testUser", token: "testToken")
        mockGetCurrentUserUseCase.mockUser = mockUser
        
        // When
        homeReducer.handle(.viewAppeared)
        
        // Then
        XCTAssertEqual(homeReducer.state.user, mockUser)
        XCTAssertFalse(homeReducer.state.isLoading)
        XCTAssertNil(homeReducer.state.errorMessage)
        XCTAssertFalse(homeReducer.state.shouldNavigateToAnnouncements)
    }
    
    func testViewAppearedWithNoUser() {
        // Given
        mockGetCurrentUserUseCase.mockUser = nil
        
        // When
        homeReducer.handle(.viewAppeared)
        
        // Then
        XCTAssertNil(homeReducer.state.user)
        XCTAssertFalse(homeReducer.state.isLoading)
        XCTAssertNil(homeReducer.state.errorMessage)
        XCTAssertFalse(homeReducer.state.shouldNavigateToAnnouncements)
    }
    
    func testLogoutClicked() {
        // Given
        let mockUser = User(account: "testUser", token: "testToken")
        homeReducer.state = HomeState(user: mockUser)
        mockLogoutUseCase.shouldSucceed = true
        
        // When
        homeReducer.handle(.logoutClicked)
        
        // Then
        XCTAssertEqual(homeReducer.state.user, mockUser)
        XCTAssertTrue(homeReducer.state.isLoading)
        XCTAssertNil(homeReducer.state.errorMessage)
        XCTAssertFalse(homeReducer.state.shouldNavigateToAnnouncements)
    }
    
    func testLogoutSuccess() {
        // Given
        let mockUser = User(account: "testUser", token: "testToken")
        homeReducer.state = HomeState(user: mockUser, isLoading: true)
        
        // When
        homeReducer.handle(.logoutSuccess)
        
        // Then
        XCTAssertNil(homeReducer.state.user)
        XCTAssertFalse(homeReducer.state.isLoading)
        XCTAssertNil(homeReducer.state.errorMessage)
        XCTAssertFalse(homeReducer.state.shouldNavigateToAnnouncements)
    }
    
    func testLogoutFailure() {
        // Given
        let mockUser = User(account: "testUser", token: "testToken")
        homeReducer.state = HomeState(user: mockUser, isLoading: true)
        let error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Logout failed"])
        
        // When
        homeReducer.handle(.logoutFailure(error))
        
        // Then
        XCTAssertEqual(homeReducer.state.user, mockUser)
        XCTAssertFalse(homeReducer.state.isLoading)
        XCTAssertEqual(homeReducer.state.errorMessage, "Logout failed")
        XCTAssertFalse(homeReducer.state.shouldNavigateToAnnouncements)
    }
    
    func testOpenAnnouncements() {
        // Given
        let mockUser = User(account: "testUser", token: "testToken")
        homeReducer.state = HomeState(user: mockUser)
        
        // When
        homeReducer.handle(.openAnnouncements)
        
        // Then
        XCTAssertEqual(homeReducer.state.user, mockUser)
        XCTAssertFalse(homeReducer.state.isLoading)
        XCTAssertNil(homeReducer.state.errorMessage)
        XCTAssertTrue(homeReducer.state.shouldNavigateToAnnouncements)
    }
}

// MARK: - Mock Classes
class MockGetCurrentUserUseCase: GetCurrentUserUseCase {
    var mockUser: User?
    
    init() {
        super.init(authRepository: MockAuthRepository())
    }
    
    override func execute() -> User? {
        return mockUser
    }
}

class MockLogoutUseCase: LogoutUseCase {
    var shouldSucceed = true
    var logoutCalled = false
    var clearUserCalled = false
    
    init() {
        super.init(authRepository: MockAuthRepository())
    }
    
    override func execute() async throws {
        logoutCalled = true
        if !shouldSucceed {
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock logout error"])
        }
        clearUserCalled = true
    }
}