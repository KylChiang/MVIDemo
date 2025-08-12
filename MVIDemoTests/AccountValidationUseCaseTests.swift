import XCTest
@testable import MVIDemo

final class AccountValidationUseCaseTests: XCTestCase {
    private var sut: AccountValidationUseCase!
    
    override func setUp() {
        super.setUp()
        sut = AccountValidationUseCaseImpl(maxLength: 10)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Valid Cases
    
    func test_validate_withEmptyAccount_returnsValid() {
        // Given
        let account = ""
        
        // When
        let result = sut.validate(account)
        
        // Then
        switch result {
        case .valid(let validAccount):
            XCTAssertEqual(validAccount, "")
        case .invalid:
            XCTFail("Expected valid result")
        }
    }
    
    func test_validate_with10Characters_returnsValid() {
        // Given
        let account = "1234567890"
        
        // When
        let result = sut.validate(account)
        
        // Then
        switch result {
        case .valid(let validAccount):
            XCTAssertEqual(validAccount, "1234567890")
        case .invalid:
            XCTFail("Expected valid result")
        }
    }
    
    func test_validate_withLessThan10Characters_returnsValid() {
        // Given
        let account = "user123"
        
        // When
        let result = sut.validate(account)
        
        // Then
        switch result {
        case .valid(let validAccount):
            XCTAssertEqual(validAccount, "user123")
        case .invalid:
            XCTFail("Expected valid result")
        }
    }
    
    // MARK: - Invalid Cases
    
    func test_validate_with11Characters_returnsInvalid() {
        // Given
        let account = "12345678901"
        
        // When
        let result = sut.validate(account)
        
        // Then
        switch result {
        case .valid:
            XCTFail("Expected invalid result")
        case .invalid(let truncatedAccount, let message):
            XCTAssertEqual(truncatedAccount, "1234567890")
            XCTAssertEqual(message, "帳號最多只能輸入10個字")
        }
    }
    
    func test_validate_withChineseCharacters_returnsInvalid() {
        // Given
        let account = "中文測試超過十個字符的輸入"
        
        // When
        let result = sut.validate(account)
        
        // Then
        switch result {
        case .valid:
            XCTFail("Expected invalid result")
        case .invalid(let truncatedAccount, let message):
            XCTAssertEqual(truncatedAccount, "中文測試超過十個字符")
            XCTAssertEqual(message, "帳號最多只能輸入10個字")
        }
    }
    
    func test_validate_withMixedCharacters_returnsInvalid() {
        // Given
        let account = "user123中文456"
        
        // When
        let result = sut.validate(account)
        
        // Then
        switch result {
        case .valid:
            XCTFail("Expected invalid result")
        case .invalid(let truncatedAccount, let message):
            XCTAssertEqual(truncatedAccount, "user123中文4")
            XCTAssertEqual(message, "帳號最多只能輸入10個字")
        }
    }
    
    // MARK: - Custom Max Length
    
    func test_validate_withCustomMaxLength_worksCorrectly() {
        // Given
        let customUseCase = AccountValidationUseCaseImpl(maxLength: 5)
        let account = "123456"
        
        // When
        let result = customUseCase.validate(account)
        
        // Then
        switch result {
        case .valid:
            XCTFail("Expected invalid result")
        case .invalid(let truncatedAccount, let message):
            XCTAssertEqual(truncatedAccount, "12345")
            XCTAssertEqual(message, "帳號最多只能輸入5個字")
        }
    }
}