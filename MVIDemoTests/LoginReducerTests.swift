import XCTest
@testable import MVIDemo

final class LoginReducerTests: XCTestCase {
    var reducer: LoginReducer!
    
    override func setUp() {
        super.setUp()
        reducer = LoginReducer()
    }
    
    override func tearDown() {
        reducer = nil
        super.tearDown()
    }
    
    func testAccountChanged() {
        // Given
        let initialState = LoginState.initial
        let account = "testUser"
        
        // When
        let newState = reducer.reduce(state: initialState, intent: .accountChanged(account))
        
        // Then
        XCTAssertEqual(newState.account, account)
        XCTAssertTrue(newState.isLoginEnabled)
        XCTAssertFalse(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
    }
    
    func testAccountChangedWithEmptyString() {
        // Given
        let initialState = LoginState.initial
        let account = ""
        
        // When
        let newState = reducer.reduce(state: initialState, intent: .accountChanged(account))
        
        // Then
        XCTAssertEqual(newState.account, account)
        XCTAssertFalse(newState.isLoginEnabled)
        XCTAssertFalse(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
    }
    
    func testLoginClicked() {
        // Given
        let initialState = LoginState(account: "testUser", isLoginEnabled: true)
        
        // When
        let newState = reducer.reduce(state: initialState, intent: .loginClicked)
        
        // Then
        XCTAssertEqual(newState.account, "testUser")
        XCTAssertTrue(newState.isLoading)
        XCTAssertFalse(newState.isLoginEnabled)
        XCTAssertNil(newState.errorMessage)
    }
    
    func testLoginSuccess() {
        // Given
        let initialState = LoginState(account: "testUser", isLoading: true)
        let user = User(account: "testUser", token: "token")
        
        // When
        let newState = reducer.reduce(state: initialState, intent: .loginSuccess(user))
        
        // Then
        XCTAssertEqual(newState.account, "testUser")
        XCTAssertFalse(newState.isLoading)
        XCTAssertTrue(newState.isLoginEnabled)
        XCTAssertNil(newState.errorMessage)
        XCTAssertEqual(newState.user, user)
    }
    
    func testLoginFailure() {
        // Given
        let initialState = LoginState(account: "testUser", isLoading: true)
        let error = LoginError.networkError
        
        // When
        let newState = reducer.reduce(state: initialState, intent: .loginFailure(error))
        
        // Then
        XCTAssertEqual(newState.account, "testUser")
        XCTAssertFalse(newState.isLoading)
        XCTAssertTrue(newState.isLoginEnabled)
        XCTAssertEqual(newState.errorMessage, error.localizedDescription)
        XCTAssertNil(newState.user)
    }
    
    func testClearError() {
        // Given
        let initialState = LoginState(account: "testUser", errorMessage: "Some error")
        
        // When
        let newState = reducer.reduce(state: initialState, intent: .clearError)
        
        // Then
        XCTAssertEqual(newState.account, "testUser")
        XCTAssertFalse(newState.isLoading)
        XCTAssertTrue(newState.isLoginEnabled)
        XCTAssertNil(newState.errorMessage)
        XCTAssertNil(newState.user)
    }
}