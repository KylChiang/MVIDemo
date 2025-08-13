//
//  ContentView.swift
//  MVIDemo
//
//  Created by Kylie on 2025/7/28.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    private let dependencyContainer: DependencyContainer
    @StateObject private var loginModel: LoginModel
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        
        // 檢查是否已有登入用戶
        let user = dependencyContainer.getCurrentUserUseCase.execute()
        self._isLoggedIn = State(initialValue: user != nil)
        
        // 創建 LoginModel 並設置回調
        let model = dependencyContainer.makeLoginModel()
        self._loginModel = StateObject(wrappedValue: model)
    }
    
    var body: some View {
        if isLoggedIn {
            HomeView(
                homeModel: dependencyContainer.makeHomeModel(),
                announcementsModel: dependencyContainer.makeAnnouncementsModel(),
                isLoggedIn: $isLoggedIn
            )
        } else {
            LoginView(
                model: loginModel,
                isLoggedIn: $isLoggedIn
            )
        }
    }
    .onAppear {
        // 設置登入成功回調
        loginModel.onLoginSuccess = {
            isLoggedIn = true
        }
    }
}

#Preview {
    ContentView(dependencyContainer: DependencyContainer())
}
