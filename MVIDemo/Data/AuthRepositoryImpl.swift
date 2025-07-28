import Foundation

class AuthRepositoryImpl: AuthRepository {
    private let userDefaults = UserDefaults.standard
    private let userKey = "current_user"
    
    func login(account: String) async throws -> User {
        // Mock API call - 模擬網路延遲
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // 簡單的 Mock 驗證 - 任何非空帳號都可以登入
        let mockToken = "mock_jwt_token_\(UUID().uuidString)"
        return User(account: account, token: mockToken)
    }
    
    func logout() async throws {
        // Mock API call
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
    }
    
    func getCurrentUser() -> User? {
        guard let data = userDefaults.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            userDefaults.set(data, forKey: userKey)
        }
    }
    
    func clearUser() {
        userDefaults.removeObject(forKey: userKey)
    }
}