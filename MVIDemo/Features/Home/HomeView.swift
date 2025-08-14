import SwiftUI

struct HomeView: View {
    @StateObject private var homeModel: HomeModel
    @StateObject private var navigationManager: NavigationManager
    private let announcementsModel: AnnouncementsModel
    private let dependencyContainer: DependencyContainer
    @Binding var isLoggedIn: Bool
    
    init(
        homeModel: HomeModel,
        navigationManager: NavigationManager,
        announcementsModel: AnnouncementsModel,
        dependencyContainer: DependencyContainer,
        isLoggedIn: Binding<Bool>
    ) {
        self._homeModel = StateObject(wrappedValue: homeModel)
        self._navigationManager = StateObject(wrappedValue: navigationManager)
        self.announcementsModel = announcementsModel
        self.dependencyContainer = dependencyContainer
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
                    // 使用新的導航系統，要求安全驗證
                    navigationManager.requestSecureAnnouncementsAccess()
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
        // 處理複雜導航狀態
        .sheet(isPresented: .constant(navigationManager.state.shouldShowSecurityVerification)) {
            if let destination = navigationManager.state.pendingDestination {
                SecurityVerificationView(
                    model: dependencyContainer.makeSecurityVerificationModel(),
                    destination: destination,
                    onSuccess: {
                        navigationManager.securityVerificationSucceeded(for: destination)
                    },
                    onCancel: {
                        navigationManager.dismissCurrentNavigation()
                    }
                )
            }
        }
        .sheet(isPresented: .constant(navigationManager.state.shouldShowAnnouncements)) {
            AnnouncementsView(model: announcementsModel)
                .onDisappear {
                    navigationManager.resetNavigation()
                }
        }
    }
}