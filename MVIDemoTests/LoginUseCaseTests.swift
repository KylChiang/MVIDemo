import XCTest
@testable import MVIDemo

class MockAuthRepository: AuthRepository {
    var shouldLoginSucceed = true
    var savedUser: User?
    var currentUser: User?
    
    func login(account: String) async throws -> User {
        if shouldLoginSucceed {
            return User(account: account, token: "mock_token")
        } else {
            throw LoginError.networkError
        }
    }
    
    func logout() async throws {
        // Mock implementation
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func saveUser(_ user: User) {
        savedUser = user
    }
    
    func clearUser() {
        savedUser = nil
        currentUser = nil
    }
}

final class LoginUseCaseTests: XCTestCase {
    var mockRepository: MockAuthRepository!
    var loginUseCase: LoginUseCase!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockAuthRepository()
        loginUseCase = LoginUseCase(authRepository: mockRepository)
    }
    
    override func tearDown() {
        mockRepository = nil
        loginUseCase = nil
        super.tearDown()
    }
    
    func testLoginWithValidAccount() async throws {
        // Given
        let account = "testUser"
        mockRepository.shouldLoginSucceed = true
        
        // When
        let user = try await loginUseCase.execute(account: account)
        
        // Then
        XCTAssertEqual(user.account, account)
        XCTAssertNotNil(user.token)
        XCTAssertEqual(mockRepository.savedUser?.account, account)
    }
    
    func testLoginWithEmptyAccount() async {
        // Given
        let account = ""
        
        // When & Then
        do {
            _ = try await loginUseCase.execute(account: account)
            XCTFail("Expected LoginError.emptyAccount")
        } catch {
            XCTAssertTrue(error is LoginError)
            XCTAssertEqual(error as? LoginError, LoginError.emptyAccount)
        }
    }
    
    func testLoginWithNetworkError() async {
        // Given
        let account = "testUser"
        mockRepository.shouldLoginSucceed = false
        
        // When & Then
        do {
            _ = try await loginUseCase.execute(account: account)
            XCTFail("Expected LoginError.networkError")
        } catch {
            XCTAssertTrue(error is LoginError)
            XCTAssertEqual(error as? LoginError, LoginError.networkError)
        }
    }
}