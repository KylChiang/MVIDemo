import Foundation

protocol AuthRepository {
    func login(account: String) async throws -> User
    func logout() async throws
    func getCurrentUser() -> User?
    func saveUser(_ user: User)
    func clearUser()
}