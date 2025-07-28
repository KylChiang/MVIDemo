import XCTest
@testable import MVIDemo

final class LoginReducerTests: XCTestCase {
    var mockRepository: MockAuthRepository!
    var loginUseCase: LoginUseCase!
    var reducer: LoginReducer!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockAuthRepository()
        loginUseCase = LoginUseCase(authRepository: mockRepository)
        reducer = LoginReducer(loginUseCase: loginUseCase)
    }
    
    override func tearDown() {
        mockRepository = nil
        loginUseCase = nil
        reducer = nil
        super.tearDown()
    }
    
    func testAccountChanged() {
        // Given
        let account = "testUser"
        
        // When
        reducer.handle(.accountChanged(account))
        
        // Then
        XCTAssertEqual(reducer.state.account, account)
        XCTAssertTrue(reducer.state.isLoginEnabled)
        XCTAssertFalse(reducer.state.isLoading)
        XCTAssertNil(reducer.state.errorMessage)
    }
    
    func testAccountChangedWithEmptyString() {
        // Given
        let account = ""
        
        // When
        reducer.handle(.accountChanged(account))
        
        // Then
        XCTAssertEqual(reducer.state.account, account)
        XCTAssertFalse(reducer.state.isLoginEnabled)
        XCTAssertFalse(reducer.state.isLoading)
        XCTAssertNil(reducer.state.errorMessage)
    }
    
    func testLoginClicked() {
        // Given
        reducer.handle(.accountChanged("testUser"))
        mockRepository.shouldLoginSucceed = true
        
        // When
        reducer.handle(.loginClicked)
        
        // Then
        XCTAssertTrue(reducer.state.isLoading)
        XCTAssertFalse(reducer.state.isLoginEnabled)
        XCTAssertNil(reducer.state.errorMessage)
    }
    
    func testLoginSuccess() {
        // Given
        let user = User(account: "testUser", token: "token")
        
        // When
        reducer.handle(.loginSuccess(user))
        
        // Then
        XCTAssertFalse(reducer.state.isLoading)
        XCTAssertTrue(reducer.state.isLoginEnabled)
        XCTAssertNil(reducer.state.errorMessage)
        XCTAssertEqual(reducer.state.user, user)
    }
    
    func testLoginFailure() {
        // Given
        let error = LoginError.networkError
        
        // When
        reducer.handle(.loginFailure(error))
        
        // Then
        XCTAssertFalse(reducer.state.isLoading)
        XCTAssertTrue(reducer.state.isLoginEnabled)
        XCTAssertEqual(reducer.state.errorMessage, error.localizedDescription)
        XCTAssertNil(reducer.state.user)
    }
}