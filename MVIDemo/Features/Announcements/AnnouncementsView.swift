import SwiftUI

struct AnnouncementsView: View {
    @StateObject private var model: AnnouncementsModel
    let onDismiss: () -> Void
    
    init(model: AnnouncementsModel, onDismiss: @escaping () -> Void = {}) {
        self._model = StateObject(wrappedValue: model)
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if model.state.isLoading && model.state.announcements.isEmpty {
                    VStack {
                        ProgressView("載入中...")
                        Spacer()
                    }
                } else if model.state.announcements.isEmpty && !model.state.isLoading {
                    VStack {
                        Text("暫無公告")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    List(model.state.announcements) { announcement in
                        AnnouncementRowView(announcement: announcement)
                    }
                    .refreshable {
                        model.handle(.refreshAnnouncements)
                    }
                }
                
                if let errorMessage = model.state.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
            }
            .navigationTitle("公告列表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回") {
                        onDismiss()
                    }
                }
            }
        }
        .onAppear {
            model.handle(.fetchAnnouncements)
        }
    }
}

struct AnnouncementRowView: View {
    let announcement: Announcement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(announcement.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(announcement.body)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}