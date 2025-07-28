import SwiftUI

struct HomeView: View {
    @StateObject private var homeReducer: HomeReducer
    private let announcementsReducer: AnnouncementsReducer
    @Binding var isLoggedIn: Bool
    @State private var showingAnnouncements = false
    
    init(
        homeReducer: HomeReducer,
        announcementsReducer: AnnouncementsReducer,
        isLoggedIn: Binding<Bool>
    ) {
        self._homeReducer = StateObject(wrappedValue: homeReducer)
        self.announcementsReducer = announcementsReducer
        self._isLoggedIn = isLoggedIn
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("主畫面")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let user = homeReducer.state.user {
                    Text("歡迎，\(user.account)")
                        .font(.title2)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Button("查看公告") {
                    showingAnnouncements = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(homeReducer.state.isLoading)
                
                if homeReducer.state.isLoading {
                    ProgressView("處理中...")
                }
                
                if let errorMessage = homeReducer.state.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("登出") {
                        homeReducer.handle(.logoutClicked)
                    }
                    .disabled(homeReducer.state.isLoading)
                }
            }
        }
        .onAppear {
            homeReducer.handle(.viewAppeared)
        }
        .onChange(of: homeReducer.state.user) { user in
            if user == nil {
                isLoggedIn = false
            }
        }
        .sheet(isPresented: $showingAnnouncements) {
            AnnouncementsView(reducer: announcementsReducer)
        }
    }
}