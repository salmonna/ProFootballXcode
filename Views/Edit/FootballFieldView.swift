//
//  FootballFieldView.swift
//  ProFootball
//

import SwiftUI

struct FootballFieldView: View {

    var items: [FieldItem]
    var trajectories: [Trajectory]

    var onTap: ((CGPoint, CGSize) -> Void)?
    var onDrag: ((CGPoint, CGSize) -> Void)?
    var onDragEnd: (() -> Void)?

    var body: some View {

        GeometryReader { geo in

            ZStack {

                Image("Football_field")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)

                ForEach(trajectories) { trajectory in
                    let isArrow = [TrajectoryType.pass, .shoot, .slalomSideToSide, .slalomRightLeg, .slalomSole,
                                   .passingRebounderNonStop, .passingRebounderPullFalsh, .passingRebounderPullPass,.controllSolePass, .controllSideToSide, .controllSole].contains(trajectory.type)

                    if isArrow,
                       trajectory.points.count == 2,
                       let first = trajectory.points.first,
                       let last = trajectory.points.last {
                        ArrowShape(
                            from: CGPoint(x: first.x, y: first.y),
                            to: CGPoint(x: last.x, y: last.y)
                        )
                        .stroke(colorForTrajectory(trajectory.type), lineWidth: 4)
                    } else {
                        Path { path in
                            guard let first = trajectory.points.first else { return }
                            path.move(to: CGPoint(x: first.x, y: first.y))
                            for point in trajectory.points.dropFirst() {
                                path.addLine(to: CGPoint(x: point.x, y: point.y))
                            }
                        }
                        .stroke(colorForTrajectory(trajectory.type), lineWidth: 4)
                    }
                }

                ForEach(items) { item in
                    Image(imageName(for: item.type))
                        .resizable()
                        .frame(width: 35, height: 35)
                        .position(x: item.x, y: item.y)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        onDrag?(value.location, geo.size)
                    }
                    .onEnded { value in
                        let dragDistance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                        if dragDistance < 5 {
                            onTap?(value.location, geo.size)
                        } else {
                            onDragEnd?()
                        }
                    }
            )
            .preference(key: FieldSizeKey.self, value: geo.size)
        }
        // 🔥 יחס קבוע 2:3 לפי מידות התמונה 740x1110
        .aspectRatio(CGSize(width: 2, height: 3), contentMode: .fit)
    }

    func imageName(for type: ItemType) -> String {
        switch type {
        case .player: return "player"
        case .cone: return "cone"
        case .kickWall: return "kickWall"
        case .agilityLadder: return "agilityLadder"
        case .ball: return "ball"
        case .rebounder: return "rebounder"
        }
    }

    func colorForTrajectory(_ type: TrajectoryType) -> Color {
        switch type {
        case .run: return .black
        case .dribble: return .blue
        case .pass: return .red
        case .shoot: return .purple
        case .highKnees: return .brown
        case .slalomSideToSide: return .orange
        case .slalomRightLeg: return .green
        case .slalomSole: return .cyan
        case .passingRebounderNonStop: return .white
        case .passingRebounderPullFalsh: return .yellow
        case .passingRebounderPullPass: return .gray
        case .controllSolePass: return .mint
        case .controllSideToSide: return .indigo
        case .controllSole: return .teal
        }
    }
}
