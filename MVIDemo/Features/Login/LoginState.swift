
/*
 
 Model Data → State
 ** 將原本 Presenter 中的狀態變數整合到 State struct

   // 舊 MVP: 分散的狀態管理
   var account: String
   var isLoading: Bool
   var errorMessage: String?

   // 新 MVI: 集中的不可變狀態
   struct LoginState: Equatable {
       let account: String
       let isLoading: Bool
       let errorMessage: String?
       // 所有 UI 狀態集中管理
   }
 
 */

import Foundation

struct LoginState: Equatable {
    let account: String
    let isLoading: Bool
    let isLoginEnabled: Bool
    let errorMessage: String?
    let user: User?
    
    init(
        account: String = "",
        isLoading: Bool = false,
        isLoginEnabled: Bool? = nil,
        errorMessage: String? = nil,
        user: User? = nil
    ) {
        self.account = account
        self.isLoading = isLoading
        self.isLoginEnabled = isLoginEnabled ?? (!account.isEmpty && !isLoading)
        self.errorMessage = errorMessage
        self.user = user
    }
    
    static let initial = LoginState()
}
