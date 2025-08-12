import SwiftUI

struct HomeView: View {
    @StateObject private var homeModel: HomeModel
    private let announcementsModel: AnnouncementsModel
    @Binding var isLoggedIn: Bool
    @State private var showingAnnouncements = false
    
    init(
        homeModel: HomeModel,
        announcementsModel: AnnouncementsModel,
        isLoggedIn: Binding<Bool>
    ) {
        self._homeModel = StateObject(wrappedValue: homeModel)
        self.announcementsModel = announcementsModel
        self._isLoggedIn = isLoggedIn
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("主畫面")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let user = homeModel.state.user {
                    Text("歡迎，\(user.account)")
                        .font(.title2)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Button("查看公告") {
                    homeModel.handle(.openAnnouncements)
                }
                .buttonStyle(.borderedProminent)
                .disabled(homeModel.state.isLoading)
                
                if homeModel.state.isLoading {
                    ProgressView("處理中...")
                }
                
                if let errorMessage = homeModel.state.errorMessage {
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
                        homeModel.handle(.logoutClicked)
                    }
                    .disabled(homeModel.state.isLoading)
                }
            }
        }
        .onAppear {
            homeModel.handle(.viewAppeared)
        }
        .onChange(of: homeModel.state.user) { user in
            if user == nil {
                isLoggedIn = false
            }
        }
        .onChange(of: homeModel.state.shouldNavigateToAnnouncements) { shouldNavigate in
            if shouldNavigate {
                showingAnnouncements = true
                homeModel.handle(.clearNavigationFlag)
            }
        }
        .sheet(isPresented: $showingAnnouncements) {
            AnnouncementsView(model: announcementsModel)
        }
    }
}