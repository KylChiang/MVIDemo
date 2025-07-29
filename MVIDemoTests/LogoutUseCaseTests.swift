import XCTest
@testable import MVIDemo

final class LogoutUseCaseTests: XCTestCase {
    var mockAuthRepository: MockAuthRepository!
    var logoutUseCase: LogoutUseCase!
    
    override func setUp() {
        super.setUp()
        mockAuthRepository = MockAuthRepository()
        logoutUseCase = LogoutUseCase(authRepository: mockAuthRepository)
    }
    
    override func tearDown() {
        mockAuthRepository = nil
        logoutUseCase = nil
        super.tearDown()
    }
    
    func testLogoutSuccess() async throws {
        // Given
        mockAuthRepository.shouldLogoutSucceed = true
        
        // When
        try await logoutUseCase.execute()
        
        // Then
        XCTAssertTrue(mockAuthRepository.logoutCalled)
        XCTAssertTrue(mockAuthRepository.clearUserCalled)
    }
    
    func testLogoutFailure() async {
        // Given
        mockAuthRepository.shouldLogoutSucceed = false
        
        // When & Then
        do {
            try await logoutUseCase.execute()
            XCTFail("Expected logout to throw an error")
        } catch {
            XCTAssertTrue(mockAuthRepository.logoutCalled)
            // clearUser should not be called if logout fails
            XCTAssertFalse(mockAuthRepository.clearUserCalled)
        }
    }
    
    func testLogoutClearsUserAfterSuccess() async throws {
        // Given
        mockAuthRepository.shouldLogoutSucceed = true
        let testUser = User(account: "testUser", token: "testToken")
        mockAuthRepository.saveUser(testUser)
        XCTAssertNotNil(mockAuthRepository.savedUser)
        
        // When
        try await logoutUseCase.execute()
        
        // Then
        XCTAssertTrue(mockAuthRepository.logoutCalled)
        XCTAssertTrue(mockAuthRepository.clearUserCalled)
        XCTAssertNil(mockAuthRepository.savedUser)
    }
}