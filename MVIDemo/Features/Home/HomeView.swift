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
                    // 觸發導航流程：請求 -> 安全驗證 -> 公告頁面
                    // 這是整個導航流程的入口點
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
        // MARK: - 導航整合 (Navigation Integration)
        // 使用 MVI 架構管理複雜的導航流程
        
        /**
         * 安全驗證頁面 Sheet
         * 當 navigationManager.state.shouldShowSecurityVerification 為 true 時顯示
         * 這是導航流程的第一步：安全驗證
         */
        .sheet(isPresented: .constant(navigationManager.state.shouldShowSecurityVerification)) {
            if let destination = navigationManager.state.pendingDestination {
                SecurityVerificationView(
                    model: dependencyContainer.makeSecurityVerificationModel(),
                    destination: destination,
                    onSuccess: {
                        // 驗證成功後通知導航管理器跳轉到目標頁面
                        // 這會觸發狀態變更：.securityVerification -> .announcements
                        navigationManager.securityVerificationSucceeded(for: destination)
                    },
                    onCancel: {
                        // 用戶取消驗證時關閉導航，狀態返回到 .none
                        navigationManager.dismissCurrentNavigation()
                    }
                )
            }
        }
        
        /**
         * 公告頁面 Sheet  
         * 當 navigationManager.state.shouldShowAnnouncements 為 true 時顯示
         * 這是導航流程的第二步：顯示目標頁面
         */
        .sheet(isPresented: .constant(navigationManager.state.shouldShowAnnouncements)) {
            AnnouncementsView(model: announcementsModel) {
                // 用戶點擊返回按鈕時重置導航狀態到 .none
                // 這裡是之前修復 "返回按鈕沒有反應" 問題的關鍵
                // 正確的狀態管理確保 UI 和狀態保持同步
                navigationManager.resetNavigation()
            }
        }
    }
}