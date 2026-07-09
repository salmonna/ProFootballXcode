//
//  CoachQuizEditorView.swift
//  ProFootball
//
//  Created by Soli Nagosa on 03/06/2026.
//

import SwiftUI
import AVKit

struct CoachQuizEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State var quiz: FootballVideoQuiz
    let onSave: (FootballVideoQuiz) -> Void

    // Video
    @State private var player: AVPlayer? = nil
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var timeObserver: Any? = nil

    // Question editing
    @State private var showQuestionEditor = false
    @State private var editingQuestion: QuizQuestion? = nil

    // Annotation (drawing) on frozen frame
    @State private var drawingPaths: [DrawingAnnotation] = []
    @State private var currentPath: [CGPoint] = []
    @State private var drawingColor: Color = .red
    @State private var drawingTool: DrawingTool = .freehand
    @State private var playerMarkers: [PlayerMarker] = []
    @State private var videoSize: CGSize = .zero

    enum DrawingTool: String, CaseIterable {
        case freehand = "pencil"
        case circle   = "circle"
        case arrow    = "arrow.up.right"
        case marker   = "person.fill.badge.plus"
        case eraser   = "eraser"
    }

    var body: some View {
        ZStack {
            Color(hex: "#080C18").ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                videoArea

                if !isPlaying {
                    annotationToolbar
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                questionsSection
                Spacer()
            }
        }
        .animation(.spring(response: 0.35), value: isPlaying)
        .sheet(isPresented: $showQuestionEditor) {
            if let q = editingQuestion {
                QuestionFormView(
                    question: q,
                    drawings: drawingPaths,
                    markers: playerMarkers,
                    timestamp: currentTime
                ) { saved in
                    if let idx = quiz.questions.firstIndex(where: { $0.id == saved.id }) {
                        quiz.questions[idx] = saved
                    } else {
                        quiz.questions.append(saved)
                    }
                    editingQuestion = nil
                    drawingPaths = []
                    playerMarkers = []
                }
            }
        }
        .onAppear { setupPlayer() }
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

            Text("עורך שאלות")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Button {
                onSave(quiz)
                dismiss()
            } label: {
                Text("שמור")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#00D4AA"))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
        .padding(.bottom, 12)
    }

    // MARK: - Video Area
    private var videoArea: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    Color(hex: "#0D1220")
                        .cornerRadius(16)

                    if let player = player {
                        VideoPlayerRepresentable(player: player)
                            .cornerRadius(16)
                            .clipped()
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "video.badge.plus")
                                .font(.system(size: 44))
                                .foregroundColor(Color(hex: "#00D4AA").opacity(0.6))
                            Text("טוען סרטון...")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B7A99"))
                        }
                    }

                    if !isPlaying {
                        DrawingOverlayView(
                            paths: $drawingPaths,
                            markers: $playerMarkers,
                            currentPath: $currentPath,
                            tool: $drawingTool,
                            color: $drawingColor,
                            size: geo.size
                        )
                        .cornerRadius(16)
                    }

                    if !isPlaying && player != nil {
                        VStack {
                            HStack {
                                Spacer()
                                Label("מושהה – סמן שחקנים וצייר", systemImage: "pause.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.black.opacity(0.65))
                                    .clipShape(Capsule())
                                    .padding(10)
                            }
                            Spacer()
                        }
                    }
                }
                .onAppear { videoSize = geo.size }
            }
            .frame(height: 220)
            .padding(.horizontal, 16)

            // Playback controls
            VStack(spacing: 8) {
                Slider(value: $currentTime, in: 0...max(duration, 1)) { editing in
                    if editing { pauseVideo() }
                    else { seekVideo(to: currentTime) }
                }
                .tint(Color(hex: "#00D4AA"))
                .padding(.horizontal, 16)

                HStack {
                    Text(formatTime(currentTime))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#6B7A99"))
                    Spacer()
                    Button { togglePlayback() } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 42))
                            .foregroundColor(Color(hex: "#00D4AA"))
                    }
                    Spacer()
                    Text(formatTime(duration))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#6B7A99"))
                }
                .padding(.horizontal, 20)

                if !isPlaying {
                    Button {
                        let newQ = QuizQuestion(
                            id: UUID(),
                            timestamp: currentTime,
                            questionText: "",
                            answers: [
                                QuizAnswerOption(text: "", isCorrect: true),
                                QuizAnswerOption(text: "", isCorrect: false),
                                QuizAnswerOption(text: "", isCorrect: false),
                                QuizAnswerOption(text: "", isCorrect: false)
                            ],
                            drawings: drawingPaths,
                            playerMarkers: playerMarkers,
                            explanation: ""
                        )
                        editingQuestion = newQ
                        showQuestionEditor = true
                    } label: {
                        Label("הוסף שאלה ב-\(formatTime(currentTime))", systemImage: "plus.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#FFB340"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 16)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Annotation Toolbar
    private var annotationToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(DrawingTool.allCases, id: \.self) { tool in
                    Button { drawingTool = tool } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tool.rawValue)
                                .font(.system(size: 18, weight: .semibold))
                            Text(toolLabel(tool))
                                .font(.system(size: 9, weight: .medium))
                        }
                        .foregroundColor(drawingTool == tool ? .black : Color(hex: "#8A9BB8"))
                        .frame(width: 56, height: 52)
                        .background(drawingTool == tool ? Color(hex: "#00D4AA") : Color(hex: "#12172A"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                Divider().frame(height: 36).background(Color(hex: "#1E2840"))

                ForEach(annotationColors, id: \.self) { hex in
                    Button { drawingColor = Color(hex: hex) } label: {
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 28, height: 28)
                            .overlay(Circle().stroke(Color.white, lineWidth: drawingColor == Color(hex: hex) ? 2 : 0))
                    }
                }

                Divider().frame(height: 36).background(Color(hex: "#1E2840"))

                Button {
                    drawingPaths = []
                    playerMarkers = []
                    currentPath = []
                } label: {
                    Label("נקה", systemImage: "trash")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#FF453A"))
                        .padding(.horizontal, 12)
                        .frame(height: 52)
                        .background(Color(hex: "#12172A"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 68)
        .background(Color(hex: "#0D1220"))
    }

    private let annotationColors = ["#FF3B30", "#00D4AA", "#FFB340", "#0A84FF", "#BF5AF2", "#FFFFFF"]

    private func toolLabel(_ tool: DrawingTool) -> String {
        switch tool {
        case .freehand: return "ציור"
        case .circle:   return "עיגול"
        case .arrow:    return "חץ"
        case .marker:   return "שחקן"
        case .eraser:   return "מחק"
        }
    }

    // MARK: - Questions Section
    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("שאלות (\(quiz.questions.count))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            if quiz.questions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "questionmark.bubble")
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: "#2A3450"))
                        Text("עצור את הסרטון והוסף שאלה")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#3D4A6B"))
                    }
                    Spacer()
                }
                .padding(.top, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(quiz.questions.enumerated()), id: \.element.id) { idx, q in
                            QuestionChip(
                                index: idx + 1,
                                timestamp: q.timestamp,
                                text: q.questionText.isEmpty ? "ללא טקסט" : q.questionText
                            ) {
                                seekVideo(to: q.timestamp)
                                pauseVideo()
                                drawingPaths  = q.drawings
                                playerMarkers = q.playerMarkers
                                editingQuestion = q
                                showQuestionEditor = true
                            } onDelete: {
                                quiz.questions.removeAll { $0.id == q.id }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    // MARK: - Player Setup
    // תומך בשני מקורות: נתיב מלא מ-Documents, ו-Bundle
    private func setupPlayer() {
        let videoName = quiz.videoName

        // ריק — אין סרטון לטעון
        guard !videoName.isEmpty else {
            print("⚠️ videoName ריק")
            return
        }

        let url: URL

        // נתיב מלא (מ-Documents / tmp / כל מקום במכשיר)
        if videoName.hasPrefix("/") {
            url = URL(fileURLWithPath: videoName)
        }
        // URL רגיל עם scheme (https:// / file://)
        else if let parsed = URL(string: videoName), parsed.scheme != nil {
            url = parsed
        }
        // שם קובץ בלבד — חפש ב-Bundle
        else if let bundleURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            url = bundleURL
        } else {
            print("⚠️ לא ניתן לפתור נתיב לסרטון: \(videoName)")
            return
        }

        // בדוק שהקובץ אכן קיים (רק לנתיבים מקומיים)
        if url.isFileURL && !FileManager.default.fileExists(atPath: url.path) {
            print("⚠️ קובץ לא קיים בנתיב: \(url.path)")
            return
        }

        let avPlayer = AVPlayer(url: url)
        self.player = avPlayer

        // עדכן duration ו-currentTime כל 0.5 שניות
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = avPlayer.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak avPlayer] time in
            guard let p = avPlayer else { return }
            currentTime = time.seconds.isNaN ? 0 : time.seconds
            if let dur = p.currentItem?.duration,
               dur.isNumeric && !dur.seconds.isNaN {
                duration = dur.seconds
            }
        }
    }

    private func cleanupPlayer() {
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
        player?.pause()
        player = nil
    }

    private func togglePlayback() {
        isPlaying ? pauseVideo() : playVideo()
    }

    private func playVideo() {
        player?.play()
        isPlaying = true
    }

    private func pauseVideo() {
        player?.pause()
        isPlaying = false
    }

    private func seekVideo(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    private func formatTime(_ t: Double) -> String {
        guard t.isFinite else { return "0:00" }
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Question Chip
struct QuestionChip: View {
    let index: Int
    let timestamp: Double
    let text: String
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("ש\(index)")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.black)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(hex: "#00D4AA"))
                    .clipShape(Capsule())

                Text(formatTime(timestamp))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(hex: "#FFB340"))

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#FF453A"))
                }
            }
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .padding(12)
        .frame(width: 160)
        .background(Color(hex: "#12172A"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#1E2840"), lineWidth: 1))
        .onTapGesture { onEdit() }
    }

    private func formatTime(_ t: Double) -> String {
        guard t.isFinite else { return "0:00" }
        return String(format: "%d:%02d", Int(t) / 60, Int(t) % 60)
    }
}

// MARK: - Drawing Overlay View
struct DrawingOverlayView: View {
    @Binding var paths: [DrawingAnnotation]
    @Binding var markers: [PlayerMarker]
    @Binding var currentPath: [CGPoint]
    @Binding var tool: CoachQuizEditorView.DrawingTool
    @Binding var color: Color
    let size: CGSize

    @State private var markerCounter = 1

    var body: some View {
        ZStack {
            Canvas { ctx, _ in
                for annotation in paths {
                    guard annotation.points.count > 1 else { continue }
                    var path = Path()
                    path.move(to: annotation.points[0])
                    for pt in annotation.points.dropFirst() { path.addLine(to: pt) }
                    ctx.stroke(path,
                               with: .color(Color(hex: annotation.color)),
                               style: StrokeStyle(lineWidth: annotation.lineWidth, lineCap: .round, lineJoin: .round))
                }
                if currentPath.count > 1 {
                    var live = Path()
                    live.move(to: currentPath[0])
                    for pt in currentPath.dropFirst() { live.addLine(to: pt) }
                    ctx.stroke(live, with: .color(color),
                               style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                }
            }

            ForEach(markers) { marker in
                let pos = CGPoint(x: marker.position.x * size.width,
                                  y: marker.position.y * size.height)
                ZStack {
                    Circle()
                        .stroke(Color(hex: marker.color), lineWidth: 3)
                        .frame(width: 36, height: 36)
                    Text(marker.label)
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(Color(hex: marker.color))
                        .offset(y: 24)
                }
                .position(pos)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { val in handleDrag(val.location, ended: false) }
                .onEnded   { val in handleDrag(val.location, ended: true)  }
        )
    }

    private func handleDrag(_ point: CGPoint, ended: Bool) {
        switch tool {
        case .marker:
            if ended {
                let norm = CGPoint(x: point.x / size.width, y: point.y / size.height)
                markers.append(PlayerMarker(position: norm, label: "#\(markerCounter)", color: uiColorHex()))
                markerCounter += 1
            }
        case .eraser:
            if ended {
                paths.removeAll { ann in ann.points.contains { dist($0, point) < 20 } }
                markers.removeAll { m in
                    let pos = CGPoint(x: m.position.x * size.width, y: m.position.y * size.height)
                    return dist(pos, point) < 24
                }
            }
        default:
            if ended {
                if !currentPath.isEmpty {
                    paths.append(DrawingAnnotation(points: currentPath, color: uiColorHex(), lineWidth: 3, type: .freehand))
                    currentPath = []
                }
            } else {
                currentPath.append(point)
            }
        }
    }

    // ממיר Color ל-hex באמצעות UIColor
    private func uiColorHex() -> String {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    private func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }
}

// MARK: - AVPlayer UIViewRepresentable
struct VideoPlayerRepresentable: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}

// UIView מותאם כך שה-AVPlayerLayer ממלא את כל הגבולות
final class PlayerUIView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
