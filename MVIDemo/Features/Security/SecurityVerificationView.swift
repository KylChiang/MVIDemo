//
//  SecurityVerificationView.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/13.
//

import SwiftUI

struct SecurityVerificationView: View {
    @StateObject private var model: SecurityVerificationModel
    @State private var password = ""
    let destination: NavigationState.SecureDestination
    let onSuccess: () -> Void
    let onCancel: () -> Void
    
    init(
        model: SecurityVerificationModel,
        destination: NavigationState.SecureDestination,
        onSuccess: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self._model = StateObject(wrappedValue: model)
        self.destination = destination
        self.onSuccess = onSuccess
        self.onCancel = onCancel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                // 標題和說明
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    
                    Text("安全驗證")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(destinationDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // 密碼輸入
                VStack(spacing: 16) {
                    SecureField("請輸入安全密碼", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            verifyPassword()
                        }
                    
                    if let errorMessage = model.state.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                // 操作按鈕
                VStack(spacing: 12) {
                    Button("驗證") {
                        verifyPassword()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(password.isEmpty || model.state.isLoading)
                    
                    Button("取消") {
                        onCancel()
                    }
                    .buttonStyle(.bordered)
                    .disabled(model.state.isLoading)
                }
                
                if model.state.isLoading {
                    ProgressView("驗證中...")
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .onChange(of: model.state.isVerificationSuccess) { isSuccess in
            if isSuccess {
                onSuccess()
            }
        }
    }
    
    private var destinationDescription: String {
        switch destination {
        case .announcements:
            return "查看公告需要安全驗證，請輸入您的安全密碼"
        case .settings:
            return "修改設定需要安全驗證，請輸入您的安全密碼"
        case .userProfile:
            return "查看個人資料需要安全驗證，請輸入您的安全密碼"
        }
    }
    
    private func verifyPassword() {
        model.handle(.verifyPassword(password))
    }
}

#Preview {
    SecurityVerificationView(
        model: DependencyContainer().makeSecurityVerificationModel(),
        destination: .announcements,
        onSuccess: {},
        onCancel: {}
    )
}