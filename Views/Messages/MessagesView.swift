////
////  MessagesView.swift
////  ProFootball
////
////  Created by Soli Nagosa on 09/06/2026.
////
//
//import SwiftUI
//
//struct MessagesView: View {
//    @StateObject private var firebase = FirebaseManager.shared
//    @State private var showCompose    = false
//    @State private var selectedMsg:   TeamMessage? = nil
//
//    var unreadCount: Int { firebase.messages.filter { !$0.isRead }.count }
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(hex: "#0A0E1A").ignoresSafeArea()
//
//                VStack(spacing: 0) {
//                    headerBar
//
//                    if firebase.messages.isEmpty {
//                        emptyState
//                    } else {
//                        messageList
//                    }
//                }
//            }
//            .navigationBarHidden(true)
//            // כפתור + פותח שיט שונה לפי תפקיד
//            .sheet(isPresented: $showCompose) {
//                if firebase.isCoach {
//                    SendQuizSheet()
//                } else {
//                    JoinRequestSheet()
//                }
//            }
//            .sheet(item: $selectedMsg) { msg in
//                MessageDetailView(message: msg)
//            }
//        }
//        .onAppear {
//            firebase.loadCurrentProfile()
//            firebase.listenToMessages()
//        }
//        .onDisappear {
//            firebase.stopListening()
//        }
//    }
//
//    // MARK: - Header
//    private var headerBar: some View {
//        HStack(alignment: .center) {
//            VStack(alignment: .leading, spacing: 4) {
//                Text("הודעות")
//                    .font(.system(size: 28, weight: .black, design: .rounded))
//                    .foregroundColor(.white)
//                Group {
//                    if unreadCount > 0 {
//                        Text("\(unreadCount) לא נקראו")
//                            .foregroundColor(Color(hex: "#00D4AA"))
//                    } else {
//                        Text("הכל עדכני ✓")
//                            .foregroundColor(Color(hex: "#3D4A6B"))
//                    }
//                }
//                .font(.system(size: 13, weight: .medium))
//            }
//
//            Spacer()
//
//            Button { showCompose = true } label: {
//                ZStack {
//                    Circle()
//                        .fill(Color(hex: "#00D4AA"))
//                        .frame(width: 44, height: 44)
//                    Image(systemName: firebase.isCoach
//                          ? "video.badge.plus"
//                          : "person.badge.plus")
//                        .font(.system(size: 18, weight: .bold))
//                        .foregroundColor(.black)
//                }
//            }
//        }
//        .padding(.horizontal, 20)
//        .padding(.top, 60)
//        .padding(.bottom, 16)
//    }
//
//    // MARK: - List
//    private var messageList: some View {
//        ScrollView {
//            LazyVStack(spacing: 10) {
//                ForEach(firebase.messages) { msg in
//                    MessageRowView(message: msg) {
//                        if let id = msg.id { firebase.markAsRead(messageId: id) }
//                        selectedMsg = msg
//                    }
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 40)
//        }
//    }
//
//    // MARK: - Empty State
//    private var emptyState: some View {
//        VStack(spacing: 16) {
//            Spacer()
//            ZStack {
//                Circle()
//                    .fill(Color(hex: "#12172A"))
//                    .frame(width: 100, height: 100)
//                Image(systemName: firebase.isCoach
//                      ? "video.badge.plus"
//                      : "person.2.fill")
//                    .font(.system(size: 38))
//                    .foregroundColor(Color(hex: "#00D4AA").opacity(0.5))
//            }
//            Text(firebase.isCoach
//                 ? "שלח שאלון לשחקן"
//                 : "הצטרף לקבוצה")
//                .font(.system(size: 20, weight: .black, design: .rounded))
//                .foregroundColor(.white)
//            Text(firebase.isCoach
//                 ? "לחץ + כדי לשלוח שאלון וידאו לשחקן"
//                 : "לחץ + כדי לשלוח בקשת הצטרפות למאמן")
//                .font(.system(size: 14))
//                .foregroundColor(Color(hex: "#3D4A6B"))
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 40)
//            Spacer()
//        }
//    }
//}
//
//// MARK: - Message Row
//struct MessageRowView: View {
//    let message: TeamMessage
//    let onTap: () -> Void
//
//    var body: some View {
//        Button(action: onTap) {
//            HStack(spacing: 14) {
//                // אייקון
//                ZStack {
//                    RoundedRectangle(cornerRadius: 14)
//                        .fill(accentColor.opacity(0.15))
//                        .frame(width: 52, height: 52)
//                    Image(systemName: iconName)
//                        .font(.system(size: 22))
//                        .foregroundColor(accentColor)
//                }
//
//                VStack(alignment: .leading, spacing: 5) {
//                    HStack {
//                        Text(message.fromName)
//                            .font(.system(size: 15, weight: .bold, design: .rounded))
//                            .foregroundColor(.white)
//                        Spacer()
//                        Text(message.timestamp.relativeFormatted)
//                            .font(.system(size: 11))
//                            .foregroundColor(Color(hex: "#3D4A6B"))
//                    }
//                    Text(subtitleText)
//                        .font(.system(size: 13))
//                        .foregroundColor(Color(hex: "#6B7A99"))
//                        .lineLimit(1)
//                }
//
//                if !message.isRead {
//                    Circle()
//                        .fill(Color(hex: "#00D4AA"))
//                        .frame(width: 9, height: 9)
//                }
//            }
//            .padding(14)
//            .background(Color(hex: "#12172A"))
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(
//                        message.isRead
//                            ? Color(hex: "#1E2840")
//                            : accentColor.opacity(0.35),
//                        lineWidth: 1
//                    )
//            )
//        }
//        .buttonStyle(.plain)
//    }
//
//    private var iconName: String {
//        switch message.type {
//        case .quizAssignment: return "play.rectangle.fill"
//        case .joinRequest:    return "person.badge.plus"
//        case .joinApproved:   return "checkmark.circle.fill"
//        case .joinRejected:   return "xmark.circle.fill"
//        case .text:           return "bubble.left.fill"
//        }
//    }
//
//    private var accentColor: Color {
//        switch message.type {
//        case .quizAssignment: return Color(hex: "#00D4AA")
//        case .joinRequest:    return Color(hex: "#FFB340")
//        case .joinApproved:   return Color(hex: "#00D4AA")
//        case .joinRejected:   return Color(hex: "#FF453A")
//        case .text:           return Color(hex: "#0A84FF")
//        }
//    }
//
//    private var subtitleText: String {
//        switch message.type {
//        case .quizAssignment: return "שאלון: \(message.quizTitle ?? "")"
//        case .joinRequest:    return "בקשת הצטרפות לקבוצה"
//        case .joinApproved:   return message.text ?? "הבקשה אושרה ✓"
//        case .joinRejected:   return "הבקשה נדחתה"
//        case .text:           return message.text ?? ""
//        }
//    }
//}
//
//// MARK: - Date Helper
//extension Date {
//    var relativeFormatted: String {
//        let diff = Date().timeIntervalSince(self)
//        if diff < 60    { return "עכשיו" }
//        if diff < 3600  { return "\(Int(diff / 60))ד'" }
//        if diff < 86400 { return "\(Int(diff / 3600))ש'" }
//        return formatted(date: .abbreviated, time: .omitted)
//    }
//}
