import Foundation

enum LoginIntent {
    case accountChanged(String)
    case loginClicked
    case loginSuccess(User)
    case loginFailure(Error)
}