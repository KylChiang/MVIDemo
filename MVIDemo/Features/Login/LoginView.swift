import SwiftUI

struct LoginView: View {
    @StateObject private var model: LoginModel
    @Binding var isLoggedIn: Bool
    
    init(model: LoginModel, isLoggedIn: Binding<Bool>) {
        self._model = StateObject(wrappedValue: model)
        self._isLoggedIn = isLoggedIn
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("登入")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("請輸入帳號", text: .init(
                    get: { model.state.account },
                    set: { model.handle(.accountChanged($0)) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(model.state.isLoading)
                
                Button("登入") {
                    model.handle(.loginClicked)
                }
                .disabled(!model.state.isLoginEnabled || model.state.isLoading)
                .buttonStyle(.borderedProminent)
                .background(Color.white)
                
                if model.state.isLoading {
                    ProgressView("登入中...")
                }
                
                if let errorMessage = model.state.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .onTapGesture {
                            model.handle(.clearError)
                        }
                }
            }
            .padding()
            .background(Color.indigo)
            .navigationBarHidden(true)
        }
        .onChange(of: model.state.user) { user in
            if user != nil {
                isLoggedIn = true
            }
        }
    }
}
