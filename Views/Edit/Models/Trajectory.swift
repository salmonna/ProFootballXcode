//
//  Trajectory.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import Foundation
import CoreGraphics

enum TrajectoryType: String, Codable {
    case run
    case dribble
    case pass
    case shoot
    case highKnees
    case slalomSideToSide
    case slalomRightLeg
    case slalomSole
    case passingRebounderNonStop
    case passingRebounderPullFalsh
    case passingRebounderPullPass
    case controllSolePass
    case controllSideToSide
    case controllSole
}

struct FieldPoint {
    var x: CGFloat
    var y: CGFloat

    var nx: CGFloat
    var ny: CGFloat
}

struct Trajectory: Identifiable {
    let id: UUID

    var type: TrajectoryType
    var points: [FieldPoint]

    init(id: UUID = UUID(), type: TrajectoryType, points: [FieldPoint]) {
        self.id = id
        self.type = type
        self.points = points
    }
}
