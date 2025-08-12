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
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        
        // 檢查是否已有登入用戶
        let user = dependencyContainer.getCurrentUserUseCase.execute()
        self._isLoggedIn = State(initialValue: user != nil)
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
                model: dependencyContainer.makeLoginModel(),
                isLoggedIn: $isLoggedIn
            )
        }
    }
}

#Preview {
    ContentView(dependencyContainer: DependencyContainer())
}
