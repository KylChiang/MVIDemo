import SwiftUI

struct AnnouncementsView: View {
    @StateObject private var reducer: AnnouncementsReducer
    @Environment(\.dismiss) private var dismiss
    
    init(reducer: AnnouncementsReducer) {
        self._reducer = StateObject(wrappedValue: reducer)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if reducer.state.isLoading && reducer.state.announcements.isEmpty {
                    VStack {
                        ProgressView("載入中...")
                        Spacer()
                    }
                } else if reducer.state.announcements.isEmpty && !reducer.state.isLoading {
                    VStack {
                        Text("暫無公告")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    List(reducer.state.announcements) { announcement in
                        AnnouncementRowView(announcement: announcement)
                    }
                    .refreshable {
                        reducer.handle(.refreshAnnouncements)
                    }
                }
                
                if let errorMessage = reducer.state.errorMessage {
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
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            reducer.handle(.fetchAnnouncements)
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