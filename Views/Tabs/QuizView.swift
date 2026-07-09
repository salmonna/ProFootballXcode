//
//  QuizView.swift
//  ProFootball
//
//  Created by Soli Nagosa on 03/06/2026.
//

import PhotosUI
import SwiftUI

struct QuizView: View {
    @State private var quizzes: [FootballVideoQuiz] = FootballVideoQuiz.sampleQuizzes
    @State private var selectedQuiz: FootballVideoQuiz? = nil
    @State private var isCoachMode = true
    @State private var showingQuiz: FootballVideoQuiz? = nil
    @State private var selectedVideo: PhotosPickerItem? = nil
    @State private var showPicker = false
    @State private var pendingQuiz: FootballVideoQuiz? = nil
    @State private var showCoachEditor = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0A0E1A")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerSection

                    modeToggle
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(quizzes) { quiz in
                                QuizCardView(quiz: quiz, isCoach: isCoachMode) {
                                    selectedQuiz = quiz
                                    showingQuiz = quiz
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            // PhotosPicker לבחירת סרטון
            .photosPicker(
                isPresented: $showPicker,
                selection: $selectedVideo,
                matching: .videos
            )
            // כשנבחר סרטון — שמור ופתח עורך
            .onChange(of: selectedVideo) { item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let url = saveVideoToDocuments(data: data) {
                        var newQuiz = newEmptyQuiz()
                        newQuiz.videoName = url.path
                        pendingQuiz = newQuiz
                        showCoachEditor = true
                    }
                    selectedVideo = nil
                }
            }
            // עורך מאמן לשאלון חדש (אחרי בחירת סרטון)
            .sheet(isPresented: $showCoachEditor) {
                if let quiz = pendingQuiz {
                    CoachQuizEditorView(quiz: quiz) { saved in
                        quizzes.insert(saved, at: 0)
                        pendingQuiz = nil
                    }
                }
            }
            // פתיחת שאלון קיים (מאמן לעריכה / שחקן למשחק)
            .fullScreenCover(item: $showingQuiz) { quiz in
                if isCoachMode {
                    CoachQuizEditorView(quiz: quiz) { updated in
                        if let idx = quizzes.firstIndex(where: { $0.id == updated.id }) {
                            quizzes[idx] = updated
                        }
                    }
                } else {
                    PlayerQuizView(quiz: quiz)
                }
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("שאלוני וידאו")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("\(quizzes.count) שאלונים זמינים")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#6B7A99"))
            }
            Spacer()
            if isCoachMode {
                Button {
                    showPicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#00D4AA"))
                            .frame(width: 44, height: 44)
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 8)
    }

    // MARK: - Mode Toggle
    private var modeToggle: some View {
        HStack(spacing: 0) {
            modeButton(title: "מאמן", icon: "person.badge.key.fill", selected: isCoachMode) {
                withAnimation(.spring(response: 0.3)) { isCoachMode = true }
            }
            modeButton(title: "שחקן", icon: "sportscourt.fill", selected: !isCoachMode) {
                withAnimation(.spring(response: 0.3)) { isCoachMode = false }
            }
        }
        .background(Color(hex: "#12172A"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func modeButton(title: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundColor(selected ? .black : Color(hex: "#6B7A99"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selected ? Color(hex: "#00D4AA") : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(3)
        }
    }

    // MARK: - Helpers
    private func newEmptyQuiz() -> FootballVideoQuiz {
        FootballVideoQuiz(
            id: UUID(),
            title: "שאלון חדש",
            videoName: "",
            thumbnailName: "",
            teamName: "",
            dateCreated: Date(),
            questions: []
        )
    }

    private func saveVideoToDocuments(data: Data) -> URL? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent("video_\(UUID().uuidString).mp4")
        do {
            try data.write(to: url)
            return url
        } catch {
            print("❌ שגיאה בשמירת סרטון: \(error)")
            return nil
        }
    }
}

// MARK: - Quiz Card
struct QuizCardView: View {
    let quiz: FootballVideoQuiz
    let isCoach: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Thumbnail placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#1A2035"))
                        .frame(width: 90, height: 64)
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#00D4AA").opacity(0.8))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(quiz.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 10) {
                        Label(quiz.teamName.isEmpty ? "ללא קבוצה" : quiz.teamName,
                              systemImage: "shield.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#00D4AA"))

                        Spacer()

                        Label("\(quiz.questions.count) שאלות",
                              systemImage: "questionmark.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#6B7A99"))
                    }

                    Text(quiz.dateCreated.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#3D4A6B"))
                }

                Image(systemName: isCoach ? "pencil.circle.fill" : "play.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(isCoach ? Color(hex: "#FFB340") : Color(hex: "#00D4AA"))
            }
            .padding(14)
            .background(Color(hex: "#12172A"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#1E2840"), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8)*17, (int >> 4 & 0xF)*17, (int & 0xF)*17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
