import Foundation

enum AccountValidationResult {
    case valid(String)
    case invalid(String, message: String)
}

protocol AccountValidationUseCase {
    func validate(_ account: String) -> AccountValidationResult
}

struct AccountValidationUseCaseImpl: AccountValidationUseCase {
    private let maxLength: Int
    
    init(maxLength: Int = 10) {
        self.maxLength = maxLength
    }
    
    func validate(_ account: String) -> AccountValidationResult {
        if account.count <= maxLength {
            return .valid(account)
        } else {
            let truncatedAccount = String(account.prefix(maxLength))
            let message = "帳號最多只能輸入\(maxLength)個字"
            return .invalid(truncatedAccount, message: message)
        }
    }
}