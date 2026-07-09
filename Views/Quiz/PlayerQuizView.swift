//
//  PlayerQuizView.swift
//  ProFootball
//
//  Created by Soli Nagosa on 03/06/2026.
//

import SwiftUI
import AVKit

struct PlayerQuizView: View {
    @Environment(\.dismiss) private var dismiss
    let quiz: FootballVideoQuiz

    // Playback
    @State private var player: AVPlayer? = nil
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var timeObserver: Any? = nil

    // Quiz state
    @State private var questionQueue: [QuizQuestion] = []
    @State private var activeQuestion: QuizQuestion? = nil
    @State private var answeredQuestions: [UUID: UUID] = [:]
    @State private var showExplanation = false
    @State private var selectedAnswerId: UUID? = nil
    @State private var isCorrect: Bool = false
    @State private var triggeredTimestamps: Set<UUID> = []

    // Results
    @State private var showResults = false
    @State private var videoSize: CGSize = .zero

    var score: Int {
        quiz.questions.filter { q in
            if let aid = answeredQuestions[q.id],
               let ans = q.answers.first(where: { $0.id == aid }) {
                return ans.isCorrect
            }
            return false
        }.count
    }

    var body: some View {
        ZStack {
            Color(hex: "#080C18").ignoresSafeArea()

            if showResults {
                ResultsView(quiz: quiz, score: score, answers: answeredQuestions) {
                    dismiss()
                }
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
            } else {
                VStack(spacing: 0) {
                    topBar
                    progressBar
                    videoSection
                    Spacer()

                    if let q = activeQuestion {
                        questionPanel(q)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else if !isPlaying && player != nil {
                        resumeHint
                    }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: activeQuestion?.id)
        .animation(.easeInOut(duration: 0.4), value: showResults)
        .onAppear { setupQuiz() }
        .onDisappear { cleanupPlayer() }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color(hex: "#1A2035"))
                    .clipShape(Circle())
            }

            Spacer()

            VStack(spacing: 2) {
                Text(quiz.title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(quiz.teamName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#00D4AA"))
            }

            Spacer()

            ZStack {
                Capsule().fill(Color(hex: "#12172A"))
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#FFB340"))
                    Text("\(score)/\(quiz.questions.count)")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .frame(height: 32)
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
        .padding(.bottom, 10)
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                ForEach(quiz.questions) { q in
                    let answered = answeredQuestions[q.id] != nil
                    let correct: Bool = {
                        guard let aid = answeredQuestions[q.id],
                              let ans = q.answers.first(where: { $0.id == aid })
                        else { return false }
                        return ans.isCorrect
                    }()
                    RoundedRectangle(cornerRadius: 3)
                        .fill(answered ? (correct ? Color(hex: "#00D4AA") : Color(hex: "#FF453A"))
                                       : Color(hex: "#1E2840"))
                        .frame(height: 5)
                        .animation(.spring(response: 0.3), value: answered)
                }
            }
            .padding(.horizontal, 16)

            Text("\(answeredQuestions.count) מתוך \(quiz.questions.count) שאלות נענו")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "#3D4A6B"))
        }
    }

    // MARK: - Video Section
    private var videoSection: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: "#0D1220").cornerRadius(16)

                if let player = player {
                    VideoPlayerRepresentable(player: player)
                        .cornerRadius(16)
                        .clipped()
                } else {
                    ProgressView()
                        .tint(Color(hex: "#00D4AA"))
                }

                if let q = activeQuestion {
                    annotationOverlay(for: q, size: geo.size)
                }
            }
            .onAppear { videoSize = geo.size }
        }
        .frame(height: 220)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: - Annotation Overlay
    private func annotationOverlay(for question: QuizQuestion, size: CGSize) -> some View {
        ZStack {
            Canvas { ctx, _ in
                for ann in question.drawings {
                    guard ann.points.count > 1 else { continue }
                    var path = Path()
                    path.move(to: ann.points[0])
                    for pt in ann.points.dropFirst() { path.addLine(to: pt) }
                    ctx.stroke(path, with: .color(Color(hex: ann.color)),
                               style: StrokeStyle(lineWidth: ann.lineWidth, lineCap: .round, lineJoin: .round))
                }
            }

            ForEach(question.playerMarkers) { marker in
                let pos = CGPoint(x: marker.position.x * size.width,
                                  y: marker.position.y * size.height)
                PulsingMarkerView(label: marker.label, color: Color(hex: marker.color))
                    .position(pos)
            }
        }
        .cornerRadius(16)
    }

    // MARK: - Question Panel
    private func questionPanel(_ q: QuizQuestion) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("⏸ סרטון הושהה")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "#FFB340"))
                Spacer()
                Text(formatTime(q.timestamp))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(hex: "#FFB340"))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Text(q.questionText)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 14)

            VStack(spacing: 8) {
                ForEach(q.answers) { ans in
                    PlayerAnswerButton(
                        answer: ans,
                        selected: selectedAnswerId == ans.id,
                        revealed: showExplanation
                    ) {
                        guard !showExplanation else { return }
                        selectAnswer(ans, for: q)
                    }
                }
            }
            .padding(.horizontal, 16)

            if showExplanation {
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isCorrect ? Color(hex: "#00D4AA") : Color(hex: "#FF453A"))
                            .font(.system(size: 20))
                        Text(isCorrect ? "נכון! כל הכבוד 🎉" : "לא נכון...")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isCorrect ? Color(hex: "#00D4AA") : Color(hex: "#FF453A"))
                    }

                    if !q.explanation.isEmpty {
                        Text(q.explanation)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#8A9BB8"))
                            .multilineTextAlignment(.center)
                    }

                    Button(action: continueVideo) {
                        Label(isLastQuestion ? "לתוצאות" : "המשך סרטון",
                              systemImage: isLastQuestion ? "trophy.fill" : "play.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(hex: "#00D4AA"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer().frame(height: 30)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "#0D1220"))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(hex: "#1E2840"), lineWidth: 1))
                .ignoresSafeArea(edges: .bottom)
        )
        .padding(.top, 8)
    }

    private var isLastQuestion: Bool {
        guard let aq = activeQuestion else { return false }
        return questionQueue.first?.id == aq.id && questionQueue.count == 1
    }

    // MARK: - Resume Hint
    private var resumeHint: some View {
        Button {
            player?.play()
            isPlaying = true
        } label: {
            Label("המשך צפייה", systemImage: "play.circle.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "#00D4AA"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 20)
        }
        .padding(.bottom, 40)
    }

    // MARK: - Setup
    private func setupQuiz() {
        questionQueue = quiz.questions.sorted { $0.timestamp < $1.timestamp }
        setupPlayer()
    }

    // תומך בנתיב מלא מ-Documents וגם ב-Bundle
    private func setupPlayer() {
        let videoName = quiz.videoName
        guard !videoName.isEmpty else { return }

        let url: URL

        if videoName.hasPrefix("/") {
            url = URL(fileURLWithPath: videoName)
        } else if let parsed = URL(string: videoName), parsed.scheme != nil {
            url = parsed
        } else if let bundleURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            url = bundleURL
        } else {
            print("⚠️ לא ניתן לפתור נתיב: \(videoName)")
            return
        }

        if url.isFileURL && !FileManager.default.fileExists(atPath: url.path) {
            print("⚠️ קובץ לא קיים: \(url.path)")
            return
        }

        let avPlayer = AVPlayer(url: url)
        self.player = avPlayer

        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = avPlayer.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak avPlayer] time in
            guard let p = avPlayer else { return }
            let t = time.seconds
            guard t.isFinite else { return }
            currentTime = t

            if let dur = p.currentItem?.duration, dur.isNumeric {
                duration = dur.seconds
            }

            // עצור כשמגיע לtimestamp של שאלה שעוד לא הופעלה
            for q in questionQueue {
                if !triggeredTimestamps.contains(q.id) && t >= q.timestamp {
                    triggeredTimestamps.insert(q.id)
                    pauseAndShow(q)
                    break
                }
            }
        }

        // התחל ניגון אוטומטי
        avPlayer.play()
        isPlaying = true
    }

    private func cleanupPlayer() {
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
        player?.pause()
        player = nil
    }

    private func pauseAndShow(_ q: QuizQuestion) {
        player?.pause()
        isPlaying = false
        showExplanation = false
        selectedAnswerId = nil
        withAnimation { activeQuestion = q }
    }

    private func selectAnswer(_ ans: QuizAnswerOption, for q: QuizQuestion) {
        selectedAnswerId = ans.id
        answeredQuestions[q.id] = ans.id
        isCorrect = ans.isCorrect
        withAnimation(.spring(response: 0.3)) { showExplanation = true }
    }

    private func continueVideo() {
        let wasLast = isLastQuestion

        withAnimation {
            activeQuestion = nil
            showExplanation = false
            selectedAnswerId = nil
        }

        if wasLast {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { showResults = true }
            }
            return
        }

        player?.play()
        isPlaying = true
    }

    private func formatTime(_ t: Double) -> String {
        guard t.isFinite else { return "0:00" }
        return String(format: "%d:%02d", Int(t) / 60, Int(t) % 60)
    }
}

// MARK: - Player Answer Button
struct PlayerAnswerButton: View {
    let answer: QuizAnswerOption
    let selected: Bool
    let revealed: Bool
    let onTap: () -> Void

    var bgColor: Color {
        if !revealed { return selected ? Color(hex: "#1E2840") : Color(hex: "#12172A") }
        if answer.isCorrect { return Color(hex: "#00D4AA").opacity(0.18) }
        if selected && !answer.isCorrect { return Color(hex: "#FF453A").opacity(0.18) }
        return Color(hex: "#12172A")
    }

    var borderColor: Color {
        if !revealed { return selected ? Color(hex: "#00D4AA") : Color(hex: "#1E2840") }
        if answer.isCorrect { return Color(hex: "#00D4AA") }
        if selected { return Color(hex: "#FF453A") }
        return Color(hex: "#1E2840")
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(borderColor.opacity(0.2))
                        .frame(width: 30, height: 30)
                    if revealed && answer.isCorrect {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(Color(hex: "#00D4AA"))
                    } else if revealed && selected && !answer.isCorrect {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(Color(hex: "#FF453A"))
                    } else {
                        Circle()
                            .fill(selected ? borderColor : Color.clear)
                            .frame(width: 10, height: 10)
                    }
                }
                Text(answer.text.isEmpty ? "—" : answer.text)
                    .font(.system(size: 15, weight: selected ? .bold : .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: selected)
        .animation(.spring(response: 0.3), value: revealed)
    }
}

// MARK: - Pulsing Marker
struct PulsingMarkerView: View {
    let label: String
    let color: Color
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 2)
                .frame(width: pulse ? 56 : 44, height: pulse ? 56 : 44)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
            Circle()
                .stroke(color, lineWidth: 3)
                .frame(width: 38, height: 38)
            Text(label)
                .font(.system(size: 9, weight: .black))
                .foregroundColor(color)
                .offset(y: 26)
        }
        .onAppear { pulse = true }
    }
}

// MARK: - Results View
struct ResultsView: View {
    let quiz: FootballVideoQuiz
    let score: Int
    let answers: [UUID: UUID]
    let onDismiss: () -> Void

    var percentage: Int {
        quiz.questions.isEmpty ? 0 : Int(Double(score) / Double(quiz.questions.count) * 100)
    }

    var grade: (String, Color) {
        switch percentage {
        case 90...100: return ("מצוין! 🏆", Color(hex: "#FFB340"))
        case 70...89:  return ("כל הכבוד! ⭐️", Color(hex: "#00D4AA"))
        case 50...69:  return ("בסדר 👍", Color(hex: "#0A84FF"))
        default:       return ("צריך לתרגל 💪", Color(hex: "#FF453A"))
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                ZStack {
                    Circle()
                        .fill(grade.1.opacity(0.15))
                        .frame(width: 120, height: 120)
                    Text(grade.0.components(separatedBy: " ").last ?? "")
                        .font(.system(size: 56))
                }

                Text(grade.0.components(separatedBy: " ").first ?? "")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(grade.1)

                ZStack {
                    Circle()
                        .stroke(Color(hex: "#1E2840"), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: CGFloat(percentage) / 100)
                        .stroke(grade.1, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1), value: percentage)
                    VStack(spacing: 4) {
                        Text("\(score)/\(quiz.questions.count)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("תשובות נכונות")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#6B7A99"))
                    }
                }
                .frame(width: 140, height: 140)

                Text("\(percentage)%")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(grade.1)

                VStack(spacing: 8) {
                    ForEach(quiz.questions) { q in
                        let correct: Bool = {
                            guard let aid = answers[q.id],
                                  let ans = q.answers.first(where: { $0.id == aid })
                            else { return false }
                            return ans.isCorrect
                        }()
                        HStack {
                            Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(correct ? Color(hex: "#00D4AA") : Color(hex: "#FF453A"))
                            Text(q.questionText.isEmpty ? "שאלה ללא טקסט" : q.questionText)
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Spacer()
                            Text(formatTime(q.timestamp))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(Color(hex: "#6B7A99"))
                        }
                        .padding(12)
                        .background(Color(hex: "#12172A"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 20)

                Button(action: onDismiss) {
                    Text("סיום")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(grade.1)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color(hex: "#080C18").ignoresSafeArea())
    }

    private func formatTime(_ t: Double) -> String {
        guard t.isFinite else { return "0:00" }
        return String(format: "%d:%02d", Int(t) / 60, Int(t) % 60)
    }
}
