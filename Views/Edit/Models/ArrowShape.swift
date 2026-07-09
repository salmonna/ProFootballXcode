//
//  ArrowShape.swift
//  ProFootball
//
//  Created by Soli Nagosa on 10/05/2026.
//

//
//  ArrowShape.swift
//  ProFootball
//

import SwiftUI

struct ArrowShape: Shape {
    var from: CGPoint
    var to: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: from)
        path.addLine(to: to)

        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength: CGFloat = 20
        let arrowAngle: CGFloat = .pi / 6

        let arrowPoint1 = CGPoint(
            x: to.x - arrowLength * cos(angle - arrowAngle),
            y: to.y - arrowLength * sin(angle - arrowAngle)
        )
        let arrowPoint2 = CGPoint(
            x: to.x - arrowLength * cos(angle + arrowAngle),
            y: to.y - arrowLength * sin(angle + arrowAngle)
        )

        path.move(to: to)
        path.addLine(to: arrowPoint1)
        path.move(to: to)
        path.addLine(to: arrowPoint2)

        return path
    }
}
