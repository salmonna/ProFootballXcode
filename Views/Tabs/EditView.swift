//
//  EditView.swift
//  ProFootball
//

import SwiftUI
import Combine

struct EditView: View {

    var drillJson: [String: Any]? = nil

    @State private var items: [FieldItem] = []
    @State private var trajectories: [Trajectory] = []
    @State private var currentTrajectory: Trajectory?
    @State private var selectedTool: ItemType?
    @State private var selectedTrajectory: TrajectoryType?
    @State private var showToolbar = false
    @State private var showTrajectories = false
    @State private var showArrows = false
    @State private var fieldSize: CGSize = .zero
    @State private var drillLoaded = false
    @StateObject private var unityVM = UnityViewModel()
    @State private var isCreatingVideo = false
    @State private var history: [ActionType] = []

    enum ActionType {
        case item
        case trajectory
    }

    var body: some View {

        ZStack(alignment: .bottom) {

            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {

                FootballFieldView(
                    items: items,
                    trajectories: trajectories + (currentTrajectory != nil ? [currentTrajectory!] : [])
                ) { point, size in
                    if selectedTrajectory == nil {
                        addItem(at: point, fieldSize: size)
                    }
                } onDrag: { point, size in
                    if selectedTool == nil {
                        drawTrajectory(point: point, size: size)
                    }
                } onDragEnd: {
                    finishTrajectory()
                }
                .onPreferenceChange(FieldSizeKey.self) { size in
                    if size.width > 0 && !drillLoaded {
                        fieldSize = size
                        loadDrillIfNeeded(fieldSize: size)
                        drillLoaded = true
                    }
                }
                .overlay(alignment: .trailing) {
                    if showToolbar {
                        toolbarPanel()
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .overlay(alignment: .leading) {
                    if showTrajectories || showArrows {
                        leftPanel()
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                }

                BottomActionBar(
                    showToolbar: $showToolbar,
                    showTrajectories: $showTrajectories,
                    showArrows: $showArrows,
                    undoAction: undo,
                    clearAction: clearField,
                    createVideoAction: createVideo
                )
            }

            // 🔥 Loading Overlay
            if isCreatingVideo {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)

                        Text("יוצר סרטון...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(40)
                    .background(Color(.darkGray).opacity(0.95))
                    .cornerRadius(20)
                }
            }
        }
        .animation(.spring(response: 0.3), value: showToolbar)
        .animation(.spring(response: 0.3), value: showTrajectories)
        .animation(.spring(response: 0.3), value: showArrows)
        .onChange(of: showToolbar) { isOpen in
            if isOpen { showTrajectories = false; showArrows = false; selectedTrajectory = nil }
        }
        .onChange(of: showTrajectories) { isOpen in
            if isOpen { showToolbar = false; showArrows = false; selectedTool = nil }
        }
        .onChange(of: showArrows) { isOpen in
            if isOpen { showToolbar = false; showTrajectories = false; selectedTool = nil }
        }
        .onReceive(NotificationCenter.default.publisher(for: .videoCreationFinished)) { _ in
            isCreatingVideo = false
        }
    }

    // MARK: - Right Panel: Items Toolbar

    @ViewBuilder
    func toolbarPanel() -> some View {
        let toolTypes: [ItemType] = [.player, .cone, .kickWall, .agilityLadder, .ball, .rebounder]

        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(toolTypes, id: \.self) { type in
                    Button {
                        selectedTool = selectedTool == type ? nil : type
                        if selectedTool != nil { showToolbar = false }
                    } label: {
                        Image(type.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .padding(8)
                            .background(selectedTool == type ? Color.blue : Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
        }
        .background(Color.black.opacity(0.5))
        .cornerRadius(16, corners: [.topLeft, .bottomLeft])
    }

    // MARK: - Left Panel: Trajectories + Arrows

    @ViewBuilder
    func leftPanel() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {

                if showTrajectories {
                    ForEach([TrajectoryType.run, .dribble, .highKnees], id: \.self) { type in
                        Button {
                            selectedTrajectory = selectedTrajectory == type ? nil : type
                            if selectedTrajectory != nil { showTrajectories = false }
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: iconForTrajectory(type))
                                    .font(.system(size: 18))
                                Text(labelForTrajectory(type))
                                    .font(.system(size: 8))
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundColor(.white)
                            .frame(width: 54, height: 54)
                            .background(selectedTrajectory == type ? Color.blue : Color.black.opacity(0.6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }

                if showArrows {
                    let arrowTypes: [TrajectoryType] = [
                        .pass, .shoot, .slalomSideToSide, .slalomRightLeg,
                        .slalomSole, .passingRebounderNonStop,
                        .passingRebounderPullFalsh, .passingRebounderPullPass,.controllSolePass, .controllSideToSide, .controllSole
                    ]
                    ForEach(arrowTypes, id: \.self) { type in
                        Button {
                            selectedTrajectory = selectedTrajectory == type ? nil : type
                            if selectedTrajectory != nil { showArrows = false }
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: iconForArrow(type))
                                    .font(.system(size: 18))
                                Text(labelForArrow(type))
                                    .font(.system(size: 8))
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundColor(.white)
                            .frame(width: 54, height: 54)
                            .background(selectedTrajectory == type ? Color.blue : Color.black.opacity(0.6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
        }
        .background(Color.black.opacity(0.5))
        .cornerRadius(16, corners: [.topRight, .bottomRight])
    }

    // MARK: - Helpers

    func iconForTrajectory(_ type: TrajectoryType) -> String {
        switch type {
        case .run: return "figure.run"
        case .dribble: return "soccerball"
        case .highKnees: return "figure.highintensity.intervaltraining"
        default: return "pencil"
        }
    }

    func labelForTrajectory(_ type: TrajectoryType) -> String {
        switch type {
        case .run: return "ריצה"
        case .dribble: return "דריבל"
        case .highKnees: return "ברכיים"
        default: return type.rawValue
        }
    }

    func iconForArrow(_ type: TrajectoryType) -> String {
        switch type {
        case .pass: return "arrow.right.circle.fill"
        case .shoot: return "arrow.up.right.circle.fill"
        case .slalomSideToSide: return "arrow.left.arrow.right.circle.fill"
        case .slalomRightLeg: return "arrow.turn.up.right"
        case .slalomSole: return "arrow.down.right.circle.fill"
        case .passingRebounderNonStop: return "arrow.triangle.2.circlepath"
        case .passingRebounderPullFalsh: return "arrow.turn.right.down"
        case .passingRebounderPullPass: return "arrow.turn.right.up"
        case .controllSolePass: return "figure.soccer"       // or any fitting SF Symbol
        case .controllSideToSide: return "figure.soccer"
        case .controllSole: return "figure.soccer"
        default: return "arrow.right"
        }
    }

    func labelForArrow(_ type: TrajectoryType) -> String {
        switch type {
        case .pass: return "פס"
        case .shoot: return "בעיטה"
        case .slalomSideToSide: return "סלאלום צדדי"
        case .slalomRightLeg: return "סלאלום ימין"
        case .slalomSole: return "סלאלום סוליה"
        case .passingRebounderNonStop: return "ריבאונד ללא עצירה"
        case .passingRebounderPullFalsh: return "ריבאונד פאלש"
        case .passingRebounderPullPass: return "ריבאונד מסירה"
        case .controllSolePass: return "שליטה סוליה פס"
        case .controllSideToSide: return "שליטה צדדית"
        case .controllSole: return "שליטה סוליה"
        default: return type.rawValue
        }
    }

    // MARK: - Load Drill

    func loadDrillIfNeeded(fieldSize: CGSize) {
        guard let drill = drillJson else { return }

        if let rawItems = drill["Items"] as? [[String: Any]] {
            items = rawItems.compactMap { i in
                guard let typeStr = i["Type"] as? String,
                      let x = i["X"] as? Double,
                      let y = i["Y"] as? Double,
                      let type = ItemType(rawValue: typeStr) else { return nil }
                return FieldItem(
                    type: type,
                    x: CGFloat(x) * fieldSize.width,
                    y: CGFloat(y) * fieldSize.height,
                    nx: CGFloat(x),
                    ny: CGFloat(y)
                )
            }
        }

        if let rawTrajectories = drill["Trajectories"] as? [[String: Any]] {
            trajectories = rawTrajectories.compactMap { t in
                guard let typeStr = t["Type"] as? String,
                      let type = TrajectoryType(rawValue: typeStr),
                      let rawPoints = t["Points"] as? [[String: Any]] else { return nil }
                let points = rawPoints.compactMap { p -> FieldPoint? in
                    guard let x = p["X"] as? Double,
                          let y = p["Y"] as? Double else { return nil }
                    return FieldPoint(
                        x: CGFloat(x) * fieldSize.width,
                        y: CGFloat(y) * fieldSize.height,
                        nx: CGFloat(x),
                        ny: CGFloat(y)
                    )
                }
                return Trajectory(type: type, points: points)
            }
        }
    }

    // MARK: - Add Item

    func addItem(at point: CGPoint, fieldSize: CGSize) {
        guard let selectedTool else { return }
        items.append(FieldItem(
            type: selectedTool,
            x: point.x, y: point.y,
            nx: point.x / fieldSize.width,
            ny: point.y / fieldSize.height
        ))
        history.append(.item)
    }

    // MARK: - Draw

    func drawTrajectory(point: CGPoint, size: CGSize) {
        guard let selectedTrajectory else { return }

        let isArrow = [TrajectoryType.pass, .shoot, .slalomSideToSide, .slalomRightLeg, .slalomSole,
                       .passingRebounderNonStop, .passingRebounderPullFalsh, .passingRebounderPullPass, .controllSolePass, .controllSideToSide, .controllSole].contains(selectedTrajectory)

        let fixedLengthArrows: [TrajectoryType: CGFloat] = [
            .pass: 0.10, .shoot: 0.10, .slalomSideToSide: 0.10,
            .slalomRightLeg: 0.10, .slalomSole: 0.10,
            .passingRebounderNonStop: 0.05, .passingRebounderPullFalsh: 0.05,
            .passingRebounderPullPass: 0.05,
            .controllSolePass: 0.10,
            .controllSideToSide: 0.10,
            .controllSole: 0.10
        ]

        let fieldPoint = FieldPoint(
            x: point.x, y: point.y,
            nx: point.x / size.width, ny: point.y / size.height
        )

        if currentTrajectory == nil {
            currentTrajectory = Trajectory(type: selectedTrajectory, points: [fieldPoint])
        } else if isArrow, let fixedLength = fixedLengthArrows[selectedTrajectory] {
            let start = currentTrajectory!.points[0]
            let dx = fieldPoint.nx - start.nx
            let dy = fieldPoint.ny - start.ny
            let distance = sqrt(dx * dx + dy * dy)
            if distance > 0.01 {
                let endNx = start.nx + (dx / distance) * fixedLength
                let endNy = start.ny + (dy / distance) * fixedLength
                currentTrajectory?.points = [start, FieldPoint(
                    x: endNx * size.width, y: endNy * size.height,
                    nx: endNx, ny: endNy
                )]
            }
        } else {
            currentTrajectory?.points.append(fieldPoint)
        }
    }

    func finishTrajectory() {
        guard let currentTrajectory else { return }

        let isRebounder = [TrajectoryType.passingRebounderNonStop, .passingRebounderPullFalsh,
                           .passingRebounderPullPass].contains(currentTrajectory.type)
        let ballTrajectories: [TrajectoryType] = [.dribble, .pass, .shoot, .slalomSideToSide,
                                                   .slalomRightLeg, .slalomSole, .passingRebounderNonStop,
                                                   .passingRebounderPullFalsh, .passingRebounderPullPass,.controllSolePass, .controllSideToSide, .controllSole]

        if ballTrajectories.contains(currentTrajectory.type), let firstPoint = currentTrajectory.points.first {
            items.append(FieldItem(id: currentTrajectory.id, type: .ball,
                x: firstPoint.x, y: firstPoint.y, nx: firstPoint.nx, ny: firstPoint.ny))
        }

        if isRebounder, let lastPoint = currentTrajectory.points.last {
            items.append(FieldItem(type: .rebounder,
                x: lastPoint.x, y: lastPoint.y, nx: lastPoint.nx, ny: lastPoint.ny))
        }
        
        // ✅ הוספת 3 קונוסים על מסלול סלאלום
        let slalomTypes: [TrajectoryType] = [.slalomSideToSide, .slalomRightLeg, .slalomSole]
        if slalomTypes.contains(currentTrajectory.type),
           let firstPoint = currentTrajectory.points.first,
           let lastPoint = currentTrajectory.points.last,
           currentTrajectory.points.count >= 2 {

            let coneCount = 3
            for i in 1...coneCount {
                let fraction = CGFloat(i) / CGFloat(coneCount + 1)

                let nx = firstPoint.nx + (lastPoint.nx - firstPoint.nx) * fraction
                let ny = firstPoint.ny + (lastPoint.ny - firstPoint.ny) * fraction

                items.append(FieldItem(
                    type: .cone,
                    x: nx * fieldSize.width,
                    y: ny * fieldSize.height,
                    nx: nx,
                    ny: ny
                ))
            }
        }

        trajectories.append(currentTrajectory)
        self.currentTrajectory = nil
        history.append(.trajectory)
    }

    // MARK: - Undo / Clear / Video

    func undo() {
        if currentTrajectory != nil {
            currentTrajectory = nil
            if !items.isEmpty { items.removeLast() }
            return
        }

        guard !history.isEmpty else { return }
        let last = history.removeLast()

        switch last {
        case .item:
            if !items.isEmpty { items.removeLast() }
        case .trajectory:
            if !trajectories.isEmpty { trajectories.removeLast() }
            if !items.isEmpty { items.removeLast() }
        }
    }

    func clearField() {
        items.removeAll()
        trajectories.removeAll()
        history.removeAll()
        currentTrajectory = nil
    }

    func createVideo() {
        isCreatingVideo = true
        unityVM.generateVideo(items: items, trajectories: trajectories)
    }
}

// MARK: - Corner Radius Helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - PreferenceKey
struct FieldSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
