//
//  MVIDemoApp.swift
//  MVIDemo
//
//  Created by Kylie on 2025/7/28.
//

import SwiftUI

@main
struct MVIDemoApp: App {
    private let dependencyContainer = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView(dependencyContainer: dependencyContainer)
        }
    }
}
