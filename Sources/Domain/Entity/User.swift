import Foundation

struct User: Codable, Equatable {
    let account: String
    let token: String
    
    init(account: String, token: String) {
        self.account = account
        self.token = token
    }
}