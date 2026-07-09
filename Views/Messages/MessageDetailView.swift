////
////  MessageDetailView.swift
////  ProFootball
////
////  Created by Soli Nagosa on 09/06/2026.
////
//
//
//import SwiftUI
//
//struct MessageDetailView: View {
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var firebase = FirebaseManager.shared
//    let message: TeamMessage
//
//    @State private var showQuiz     = false
//    @State private var quizToPlay:  FootballVideoQuiz? = nil
//    @State private var isProcessing = false
//    @State private var errorMsg:    String?
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(hex: "#0A0E1A").ignoresSafeArea()
//
//                ScrollView {
//                    VStack(spacing: 24) {
//                        iconHeader
//                        contentCard
//                        actionSection
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 20)
//                    .padding(.bottom, 60)
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text(message.fromName)
//                        .font(.system(size: 17, weight: .black, design: .rounded))
//                        .foregroundColor(.white)
//                }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button { dismiss() } label: {
//                        Image(systemName: "xmark")
//                            .foregroundColor(Color(hex: "#6B7A99"))
//                    }
//                }
//            }
//            .fullScreenCover(isPresented: $showQuiz) {
//                if let quiz = quizToPlay { PlayerQuizView(quiz: quiz) }
//            }
//        }
//    }
//
//    // MARK: - Icon Header
//    private var iconHeader: some View {
//        VStack(spacing: 12) {
//            ZStack {
//                Circle()
//                    .fill(accentColor.opacity(0.15))
//                    .frame(width: 90, height: 90)
//                Image(systemName: headerIcon)
//                    .font(.system(size: 38))
//                    .foregroundColor(accentColor)
//            }
//            Text(headerTitle)
//                .font(.system(size: 22, weight: .black, design: .rounded))
//                .foregroundColor(.white)
//            Text(message.timestamp.formatted(date: .long, time: .shortened))
//                .font(.system(size: 12))
//                .foregroundColor(Color(hex: "#3D4A6B"))
//        }
//    }
//
//    // MARK: - Content Card
//    @ViewBuilder
//    private var contentCard: some View {
//        switch message.type {
//
//        case .quizAssignment:
//            VStack(spacing: 0) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 14)
//                        .fill(Color(hex: "#0D1220"))
//                        .frame(height: 150)
//                    VStack(spacing: 8) {
//                        Image(systemName: "play.rectangle.fill")
//                            .font(.system(size: 46))
//                            .foregroundColor(Color(hex: "#00D4AA").opacity(0.7))
//                        Text("סרטון מאמן")
//                            .font(.system(size: 12))
//                            .foregroundColor(Color(hex: "#6B7A99"))
//                    }
//                }
//                VStack(alignment: .leading, spacing: 10) {
//                    Label(message.quizTitle ?? "שאלון", systemImage: "sportscourt.fill")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(.white)
//                    Label("נשלח מ: \(message.fromName)", systemImage: "person.badge.key.fill")
//                        .font(.system(size: 13))
//                        .foregroundColor(Color(hex: "#6B7A99"))
//                    Divider().background(Color(hex: "#1E2840"))
//                    Text("צפה בסרטון וענה על השאלות")
//                        .font(.system(size: 13))
//                        .foregroundColor(Color(hex: "#6B7A99"))
//                }
//                .padding(16)
//                .background(Color(hex: "#12172A"))
//                .clipShape(RoundedRectangle(cornerRadius: 14))
//            }
//
//        case .joinRequest:
//            VStack(spacing: 14) {
//                HStack(spacing: 14) {
//                    ZStack {
//                        Circle().fill(Color(hex: "#FFB340").opacity(0.15)).frame(width: 50, height: 50)
//                        Text(String(message.fromName.prefix(1)))
//                            .font(.system(size: 20, weight: .black))
//                            .foregroundColor(Color(hex: "#FFB340"))
//                    }
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(message.fromName)
//                            .font(.system(size: 16, weight: .bold))
//                            .foregroundColor(.white)
//                        Text("מבקש להצטרף לקבוצה")
//                            .font(.system(size: 13))
//                            .foregroundColor(Color(hex: "#6B7A99"))
//                    }
//                    Spacer()
//                }
//                // סטטוס קיים
//                if let status = message.status, status != .pending {
//                    HStack(spacing: 6) {
//                        Image(systemName: status == .approved ? "checkmark.circle.fill" : "xmark.circle.fill")
//                        Text(status == .approved ? "אושר" : "נדחה")
//                    }
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundColor(status == .approved ? Color(hex: "#00D4AA") : Color(hex: "#FF453A"))
//                    .padding(.horizontal, 16).padding(.vertical, 8)
//                    .background(
//                        (status == .approved ? Color(hex: "#00D4AA") : Color(hex: "#FF453A")).opacity(0.12)
//                    )
//                    .clipShape(Capsule())
//                }
//            }
//            .padding(18)
//            .background(Color(hex: "#12172A"))
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#1E2840"), lineWidth: 1))
//
//        case .joinApproved, .joinRejected:
//            HStack(spacing: 12) {
//                Image(systemName: message.type == .joinApproved ? "checkmark.seal.fill" : "xmark.seal.fill")
//                    .font(.system(size: 28))
//                    .foregroundColor(accentColor)
//                Text(message.text ?? (message.type == .joinApproved ? "הצטרפת לקבוצה!" : "הבקשה נדחתה"))
//                    .font(.system(size: 16, weight: .bold))
//                    .foregroundColor(.white)
//            }
//            .padding(18)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(Color(hex: "#12172A"))
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .overlay(RoundedRectangle(cornerRadius: 16).stroke(accentColor.opacity(0.3), lineWidth: 1))
//
//        case .text:
//            Text(message.text ?? "")
//                .font(.system(size: 16))
//                .foregroundColor(.white)
//                .padding(18)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(Color(hex: "#12172A"))
//                .clipShape(RoundedRectangle(cornerRadius: 16))
//                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#1E2840"), lineWidth: 1))
//        }
//    }
//
//    // MARK: - Actions
//    @ViewBuilder
//    private var actionSection: some View {
//        // שחקן — התחל שאלון
//        if message.type == .quizAssignment {
//            Button { buildAndPlay() } label: {
//                Label("התחל שאלון", systemImage: "play.fill")
//                    .font(.system(size: 17, weight: .black, design: .rounded))
//                    .foregroundColor(.black)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(Color(hex: "#00D4AA"))
//                    .clipShape(RoundedRectangle(cornerRadius: 14))
//            }
//        }
//
//        // מאמן — אשר / דחה בקשת הצטרפות ממתינה
//        if message.type == .joinRequest,
//           message.status == .pending,
//           firebase.isCoach {
//            HStack(spacing: 12) {
//                Button {
//                    Task { await respond(approve: false) }
//                } label: {
//                    Label("דחה", systemImage: "xmark")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(Color(hex: "#FF453A"))
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 14)
//                        .background(Color(hex: "#FF453A").opacity(0.12))
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        .overlay(RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color(hex: "#FF453A").opacity(0.4), lineWidth: 1))
//                }
//
//                Button {
//                    Task { await respond(approve: true) }
//                } label: {
//                    Group {
//                        if isProcessing {
//                            ProgressView().tint(.black).scaleEffect(0.85)
//                        } else {
//                            Label("אשר", systemImage: "checkmark")
//                                .font(.system(size: 16, weight: .bold))
//                                .foregroundColor(.black)
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 14)
//                    .background(Color(hex: "#00D4AA"))
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                }
//                .disabled(isProcessing)
//            }
//        }
//
//        if let err = errorMsg {
//            Text(err)
//                .font(.system(size: 13))
//                .foregroundColor(Color(hex: "#FF453A"))
//                .multilineTextAlignment(.center)
//        }
//    }
//
//    // MARK: - Logic
//    private func buildAndPlay() {
//        // בנה FootballVideoQuiz מ-message.videoURL
//        // במימוש מלא — טען שאלות מ-Firestore לפי message.quizId
//        let quiz = FootballVideoQuiz(
//            id:           UUID(),
//            title:        message.quizTitle ?? "שאלון",
//            videoName:    message.videoURL  ?? "",
//            thumbnailName: "",
//            teamName:     message.fromName,
//            dateCreated:  message.timestamp,
//            questions:    []
//        )
//        quizToPlay = quiz
//        showQuiz   = true
//    }
//
//    private func respond(approve: Bool) async {
//        isProcessing = true
//        errorMsg = nil
//        do {
//            try await firebase.respondToJoinRequest(message: message, approve: approve)
//            dismiss()
//        } catch {
//            errorMsg = "שגיאה: \(error.localizedDescription)"
//        }
//        isProcessing = false
//    }
//
//    // MARK: - Computed
//    private var headerIcon: String {
//        switch message.type {
//        case .quizAssignment: return "play.rectangle.fill"
//        case .joinRequest:    return "person.badge.plus"
//        case .joinApproved:   return "checkmark.seal.fill"
//        case .joinRejected:   return "xmark.seal.fill"
//        case .text:           return "bubble.left.fill"
//        }
//    }
//    private var headerTitle: String {
//        switch message.type {
//        case .quizAssignment: return "שאלון חדש"
//        case .joinRequest:    return "בקשת הצטרפות"
//        case .joinApproved:   return "הבקשה אושרה"
//        case .joinRejected:   return "הבקשה נדחתה"
//        case .text:           return "הודעה"
//        }
//    }
//    private var accentColor: Color {
//        switch message.type {
//        case .quizAssignment: return Color(hex: "#00D4AA")
//        case .joinRequest:    return Color(hex: "#FFB340")
//        case .joinApproved:   return Color(hex: "#00D4AA")
//        case .joinRejected:   return Color(hex: "#FF453A")
//        case .text:           return Color(hex: "#0A84FF")
//        }
//    }
//}
