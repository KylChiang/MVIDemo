import SwiftUI

struct LoginView: View {
    @StateObject private var reducer: LoginReducer
    @Binding var isLoggedIn: Bool
    
    init(reducer: LoginReducer, isLoggedIn: Binding<Bool>) {
        self._reducer = StateObject(wrappedValue: reducer)
        self._isLoggedIn = isLoggedIn
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("登入")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("請輸入帳號", text: .init(
                    get: { reducer.state.account },
                    set: { reducer.handle(.accountChanged($0)) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(reducer.state.isLoading)
                
                Button("登入") {
                    reducer.handle(.loginClicked)
                }
                .disabled(!reducer.state.isLoginEnabled || reducer.state.isLoading)
                .buttonStyle(.borderedProminent)
                
                if reducer.state.isLoading {
                    ProgressView("登入中...")
                }
                
                if let errorMessage = reducer.state.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
        .onChange(of: reducer.state.user) { user in
            if user != nil {
                isLoggedIn = true
            }
        }
    }
}