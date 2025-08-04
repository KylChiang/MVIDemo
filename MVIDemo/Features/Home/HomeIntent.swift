import Foundation

enum HomeIntent: Equatable {
    case viewAppeared
    case userLoaded(User?)
    case logoutClicked
    case logoutSuccess
    case logoutFailure(Error)
    case openAnnouncements
    case clearNavigationFlag
    
    static func == (lhs: HomeIntent, rhs: HomeIntent) -> Bool {
        switch (lhs, rhs) {
        case (.viewAppeared, .viewAppeared):
            return true
        case (.userLoaded(let lhsUser), .userLoaded(let rhsUser)):
            return lhsUser == rhsUser
        case (.logoutClicked, .logoutClicked):
            return true
        case (.logoutSuccess, .logoutSuccess):
            return true
        case (.logoutFailure(let lhsError), .logoutFailure(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.openAnnouncements, .openAnnouncements):
            return true
        case (.clearNavigationFlag, .clearNavigationFlag):
            return true
        default:
            return false
        }
    }
}