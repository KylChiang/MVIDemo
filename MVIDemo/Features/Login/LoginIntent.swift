
/*
 
 Intent 統一用戶行為

   // MVI 新增：明確定義所有用戶意圖
   enum LoginIntent {
       case accountChanged(String)
       case loginClicked
       case loginSuccess(User)
       case loginFailure(Error)
   }
 
 */

import Foundation

enum LoginIntent: Equatable {
    case accountChanged(String)
    case loginClicked
    case loginSuccess(User)
    case loginFailure(Error)
    case clearError
    case accountValidationFailed(String)
    
    static func == (lhs: LoginIntent, rhs: LoginIntent) -> Bool {
        switch (lhs, rhs) {
        case (.accountChanged(let lhsAccount), .accountChanged(let rhsAccount)):
            return lhsAccount == rhsAccount
        case (.loginClicked, .loginClicked):
            return true
        case (.loginSuccess(let lhsUser), .loginSuccess(let rhsUser)):
            return lhsUser == rhsUser
        case (.loginFailure(let lhsError), .loginFailure(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.clearError, .clearError):
            return true
        case (.accountValidationFailed(let lhsMessage), .accountValidationFailed(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
