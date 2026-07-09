////
////  SendQuizSheet.swift
////  ProFootball
////
////  Created by Soli Nagosa on 09/06/2026.
////
//
//
//import SwiftUI
//
//struct SendQuizSheet: View {
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var firebase = FirebaseManager.shared
//
//    // בפרויקט האמיתי תעביר את הרשימה מ-QuizView דרך @Binding או EnvironmentObject
//    // לדמו — sample
//    let availableQuizzes: [FootballVideoQuiz] = FootballVideoQuiz.sampleQuizzes
//
//    @State private var selectedQuiz:   FootballVideoQuiz? = nil
//    @State private var selectedUid:    String?            = nil
//    @State private var selectedName:   String             = ""
//    @State private var uploadProgress: Double             = 0
//    @State private var isSending       = false
//    @State private var didSend         = false
//    @State private var errorMsg:       String?
//
//    private var canSend: Bool {
//        selectedQuiz != nil && selectedUid != nil && !isSending
//    }
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(hex: "#0A0E1A").ignoresSafeArea()
//
//                if didSend {
//                    successView
//                } else {
//                    ScrollView {
//                        VStack(spacing: 28) {
//                            sectionTitle("בחר שאלון", icon: "play.rectangle.fill", color: "#00D4AA")
//                            quizPicker
//
//                            sectionTitle("בחר שחקן", icon: "person.fill", color: "#FFB340")
//                            playerPicker
//
//                            if isSending { progressSection }
//
//                            sendButton
//
//                            if let err = errorMsg {
//                                Text(err)
//                                    .font(.system(size: 13))
//                                    .foregroundColor(Color(hex: "#FF453A"))
//                                    .multilineTextAlignment(.center)
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.top, 10)
//                        .padding(.bottom, 60)
//                    }
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("שלח שאלון")
//                        .font(.system(size: 17, weight: .black, design: .rounded))
//                        .foregroundColor(.white)
//                }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("ביטול") { dismiss() }
//                        .foregroundColor(Color(hex: "#6B7A99"))
//                }
//            }
//        }
//    }
//
//    // MARK: - Quiz Picker
//    private var quizPicker: some View {
//        VStack(spacing: 8) {
//            if availableQuizzes.isEmpty {
//                emptyPickerHint("אין שאלונים — צור שאלון קודם מהטאב שאלונים")
//            } else {
//                ForEach(availableQuizzes) { quiz in
//                    selectionRow(
//                        isSelected: selectedQuiz?.id == quiz.id,
//                        accentHex: "#00D4AA"
//                    ) {
//                        selectedQuiz = quiz
//                    } content: {
//                        HStack(spacing: 12) {
//                            Image(systemName: "play.rectangle.fill")
//                                .font(.system(size: 20))
//                                .foregroundColor(Color(hex: "#00D4AA").opacity(0.7))
//                                .frame(width: 36)
//                            VStack(alignment: .leading, spacing: 3) {
//                                Text(quiz.title)
//                                    .font(.system(size: 15, weight: .bold))
//                                    .foregroundColor(.white)
//                                Text("\(quiz.questions.count) שאלות")
//                                    .font(.system(size: 12))
//                                    .foregroundColor(Color(hex: "#6B7A99"))
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: - Player Picker
//    private var playerPicker: some View {
//        VStack(spacing: 8) {
//            if firebase.teamPlayers.isEmpty {
//                emptyPickerHint("אין שחקנים בקבוצה עדיין.\nשחקנים יופיעו כאן לאחר שיאשר בקשת הצטרפות.")
//            } else {
//                ForEach(Array(firebase.teamPlayers), id: \.key) { uid, profile in
//                    selectionRow(
//                        isSelected: selectedUid == uid,
//                        accentHex: "#FFB340"
//                    ) {
//                        selectedUid  = uid
//                        selectedName = "\(profile.firstName) \(profile.lastName)"
//                    } content: {
//                        HStack(spacing: 12) {
//                            ZStack {
//                                Circle()
//                                    .fill(Color(hex: "#FFB340").opacity(0.2))
//                                    .frame(width: 38, height: 38)
//                                Text(String(profile.firstName.prefix(1)))
//                                    .font(.system(size: 16, weight: .black))
//                                    .foregroundColor(Color(hex: "#FFB340"))
//                            }
//                            VStack(alignment: .leading, spacing: 3) {
//                                Text("\(profile.firstName) \(profile.lastName)")
//                                    .font(.system(size: 15, weight: .bold))
//                                    .foregroundColor(.white)
//                                Text(profile.position ?? profile.email)
//                                    .font(.system(size: 12))
//                                    .foregroundColor(Color(hex: "#6B7A99"))
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: - Progress
//    private var progressSection: some View {
//        VStack(spacing: 8) {
//            ProgressView(value: uploadProgress)
//                .tint(Color(hex: "#00D4AA"))
//            Text(uploadProgress < 0.99
//                 ? "מעלה סרטון... \(Int(uploadProgress * 100))%"
//                 : "שולח הודעה...")
//                .font(.system(size: 13))
//                .foregroundColor(Color(hex: "#6B7A99"))
//        }
//    }
//
//    // MARK: - Send Button
//    private var sendButton: some View {
//        Button {
//            Task { await doSend() }
//        } label: {
//            HStack(spacing: 8) {
//                if isSending {
//                    ProgressView().tint(.black).scaleEffect(0.8)
//                } else {
//                    Image(systemName: "paperplane.fill")
//                }
//                Text(isSending ? "שולח..." : "שלח שאלון")
//                    .font(.system(size: 17, weight: .black, design: .rounded))
//            }
//            .foregroundColor(.black)
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 16)
//            .background(canSend ? Color(hex: "#00D4AA") : Color(hex: "#2A3450"))
//            .clipShape(RoundedRectangle(cornerRadius: 14))
//        }
//        .disabled(!canSend)
//    }
//
//    // MARK: - Success
//    private var successView: some View {
//        VStack(spacing: 20) {
//            Spacer()
//            ZStack {
//                Circle().fill(Color(hex: "#00D4AA").opacity(0.15)).frame(width: 120, height: 120)
//                Image(systemName: "checkmark.circle.fill")
//                    .font(.system(size: 56))
//                    .foregroundColor(Color(hex: "#00D4AA"))
//            }
//            Text("השאלון נשלח! 🎉")
//                .font(.system(size: 26, weight: .black, design: .rounded))
//                .foregroundColor(.white)
//            if let quiz = selectedQuiz {
//                Text("\"\(quiz.title)\" נשלח ל-\(selectedName)")
//                    .font(.system(size: 14))
//                    .foregroundColor(Color(hex: "#6B7A99"))
//                    .multilineTextAlignment(.center)
//            }
//            Spacer()
//            Button { dismiss() } label: {
//                Text("סגור")
//                    .font(.system(size: 17, weight: .black))
//                    .foregroundColor(.black)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(Color(hex: "#00D4AA"))
//                    .clipShape(RoundedRectangle(cornerRadius: 14))
//                    .padding(.horizontal, 20)
//            }
//            .padding(.bottom, 40)
//        }
//    }
//
//    // MARK: - Logic
//    private func doSend() async {
//        guard let quiz = selectedQuiz, let uid = selectedUid else { return }
//        isSending  = true
//        errorMsg   = nil
//        uploadProgress = 0
//        do {
//            try await firebase.sendQuizAssignment(
//                quiz: quiz,
//                toUid: uid,
//                toName: selectedName,
//                onProgress: { uploadProgress = $0 }
//            )
//            withAnimation { didSend = true }
//        } catch {
//            errorMsg = "שגיאה: \(error.localizedDescription)"
//        }
//        isSending = false
//    }
//
//    // MARK: - Helpers
//    private func sectionTitle(_ text: String, icon: String, color: String) -> some View {
//        HStack(spacing: 8) {
//            Image(systemName: icon).font(.system(size: 13, weight: .bold))
//                .foregroundColor(Color(hex: color))
//            Text(text).font(.system(size: 14, weight: .bold, design: .rounded))
//                .foregroundColor(Color(hex: color))
//            Spacer()
//        }
//    }
//
//    private func emptyPickerHint(_ text: String) -> some View {
//        Text(text)
//            .font(.system(size: 13))
//            .foregroundColor(Color(hex: "#3D4A6B"))
//            .multilineTextAlignment(.center)
//            .padding(.vertical, 16)
//            .frame(maxWidth: .infinity)
//            .background(Color(hex: "#12172A"))
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//    }
//
//    private func selectionRow<Content: View>(
//        isSelected: Bool,
//        accentHex: String,
//        onTap: @escaping () -> Void,
//        @ViewBuilder content: () -> Content
//    ) -> some View {
//        Button(action: onTap) {
//            HStack {
//                content()
//                Spacer()
//                if isSelected {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(Color(hex: accentHex))
//                        .font(.system(size: 20))
//                }
//            }
//            .padding(14)
//            .background(isSelected ? Color(hex: accentHex).opacity(0.1) : Color(hex: "#12172A"))
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(
//                        isSelected ? Color(hex: accentHex).opacity(0.5) : Color(hex: "#1E2840"),
//                        lineWidth: 1
//                    )
//            )
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// MARK: - Join Request Sheet (שחקן מחפש מאמן)
//struct JoinRequestSheet: View {
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var firebase = FirebaseManager.shared
//
//    @State private var coachEmail  = ""
//    @State private var foundUid:   String?      = nil
//    @State private var foundName:  String       = ""
//    @State private var isSearching = false
//    @State private var isSending   = false
//    @State private var didSend     = false
//    @State private var errorMsg:   String?
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(hex: "#0A0E1A").ignoresSafeArea()
//
//                if didSend {
//                    sentView
//                } else {
//                    VStack(spacing: 24) {
//                        // Header
//                        VStack(spacing: 10) {
//                            Image(systemName: "person.badge.key.fill")
//                                .font(.system(size: 44))
//                                .foregroundColor(Color(hex: "#FFB340"))
//                            Text("הצטרף לקבוצה")
//                                .font(.system(size: 22, weight: .black, design: .rounded))
//                                .foregroundColor(.white)
//                            Text("הזן את כתובת המייל של המאמן שלך")
//                                .font(.system(size: 14))
//                                .foregroundColor(Color(hex: "#6B7A99"))
//                                .multilineTextAlignment(.center)
//                        }
//                        .padding(.top, 20)
//
//                        // שדה מייל + כפתור חיפוש
//                        VStack(spacing: 10) {
//                            HStack(spacing: 10) {
//                                Image(systemName: "envelope.fill")
//                                    .foregroundColor(Color(hex: "#6B7A99"))
//                                TextField("מייל המאמן", text: $coachEmail)
//                                    .keyboardType(.emailAddress)
//                                    .autocapitalization(.none)
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 15))
//                                if isSearching {
//                                    ProgressView().tint(Color(hex: "#00D4AA")).scaleEffect(0.75)
//                                }
//                            }
//                            .padding(14)
//                            .background(Color(hex: "#12172A"))
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color(hex: "#1E2840"), lineWidth: 1)
//                            )
//
//                            Button {
//                                Task { await doSearch() }
//                            } label: {
//                                Text("חפש מאמן")
//                                    .font(.system(size: 15, weight: .bold))
//                                    .foregroundColor(coachEmail.isEmpty ? Color(hex: "#3D4A6B") : Color(hex: "#00D4AA"))
//                            }
//                            .disabled(coachEmail.isEmpty || isSearching)
//                        }
//
//                        // כרטיס מאמן שנמצא
//                        if let uid = foundUid {
//                            HStack(spacing: 14) {
//                                ZStack {
//                                    Circle().fill(Color(hex: "#00D4AA").opacity(0.2)).frame(width: 48, height: 48)
//                                    Text(String(foundName.prefix(1)))
//                                        .font(.system(size: 20, weight: .black))
//                                        .foregroundColor(Color(hex: "#00D4AA"))
//                                }
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text(foundName)
//                                        .font(.system(size: 16, weight: .bold))
//                                        .foregroundColor(.white)
//                                    Label("מאמן", systemImage: "person.badge.key.fill")
//                                        .font(.system(size: 12))
//                                        .foregroundColor(Color(hex: "#00D4AA"))
//                                }
//                                Spacer()
//                                Image(systemName: "checkmark.circle.fill")
//                                    .font(.system(size: 22))
//                                    .foregroundColor(Color(hex: "#00D4AA"))
//                            }
//                            .padding(16)
//                            .background(Color(hex: "#12172A"))
//                            .clipShape(RoundedRectangle(cornerRadius: 14))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 14)
//                                    .stroke(Color(hex: "#00D4AA").opacity(0.3), lineWidth: 1)
//                            )
//
//                            Button {
//                                Task { await doSendRequest(toUid: uid) }
//                            } label: {
//                                Group {
//                                    if isSending {
//                                        ProgressView().tint(.black).scaleEffect(0.85)
//                                    } else {
//                                        Label("שלח בקשת הצטרפות", systemImage: "paperplane.fill")
//                                            .font(.system(size: 17, weight: .black, design: .rounded))
//                                    }
//                                }
//                                .foregroundColor(.black)
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 16)
//                                .background(Color(hex: "#FFB340"))
//                                .clipShape(RoundedRectangle(cornerRadius: 14))
//                            }
//                            .disabled(isSending)
//                        }
//
//                        if let err = errorMsg {
//                            Text(err)
//                                .font(.system(size: 13))
//                                .foregroundColor(Color(hex: "#FF453A"))
//                                .multilineTextAlignment(.center)
//                        }
//
//                        Spacer()
//                    }
//                    .padding(.horizontal, 20)
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("הצטרף לקבוצה")
//                        .font(.system(size: 17, weight: .black, design: .rounded))
//                        .foregroundColor(.white)
//                }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("ביטול") { dismiss() }
//                        .foregroundColor(Color(hex: "#6B7A99"))
//                }
//            }
//        }
//    }
//
//    private var sentView: some View {
//        VStack(spacing: 20) {
//            Spacer()
//            ZStack {
//                Circle().fill(Color(hex: "#FFB340").opacity(0.15)).frame(width: 120, height: 120)
//                Image(systemName: "paperplane.fill")
//                    .font(.system(size: 50))
//                    .foregroundColor(Color(hex: "#FFB340"))
//            }
//            Text("הבקשה נשלחה! ✅")
//                .font(.system(size: 26, weight: .black, design: .rounded))
//                .foregroundColor(.white)
//            Text("המאמן יאשר את הבקשה בהקדם")
//                .font(.system(size: 14))
//                .foregroundColor(Color(hex: "#6B7A99"))
//            Spacer()
//            Button { dismiss() } label: {
//                Text("סגור")
//                    .font(.system(size: 17, weight: .black))
//                    .foregroundColor(.black)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(Color(hex: "#FFB340"))
//                    .clipShape(RoundedRectangle(cornerRadius: 14))
//                    .padding(.horizontal, 20)
//            }
//            .padding(.bottom, 40)
//        }
//    }
//
//    // MARK: - Logic
//    private func doSearch() async {
//        isSearching = true
//        errorMsg    = nil
//        foundUid    = nil
//        do {
//            if let result = try await firebase.searchCoach(byEmail: coachEmail) {
//                foundUid  = result.uid
//                foundName = "\(result.profile.firstName) \(result.profile.lastName)"
//            } else {
//                errorMsg = "לא נמצא מאמן עם המייל הזה"
//            }
//        } catch {
//            errorMsg = "שגיאת חיפוש: \(error.localizedDescription)"
//        }
//        isSearching = false
//    }
//
//    private func doSendRequest(toUid: String) async {
//        isSending = true
//        errorMsg  = nil
//        do {
//            try await firebase.sendJoinRequest(toCoachUid: toUid, toCoachName: foundName)
//            withAnimation { didSend = true }
//        } catch {
//            errorMsg = "שגיאה: \(error.localizedDescription)"
//        }
//        isSending = false
//    }
//}
