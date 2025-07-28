import Foundation

enum HomeIntent {
    case viewAppeared
    case logoutClicked
    case logoutSuccess
    case logoutFailure(Error)
    case openAnnouncements
}