//
//  FieldItem.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import Foundation
import CoreGraphics

enum ItemType: String, Codable {
    case player
    case cone
    case kickWall
    case agilityLadder
    case ball
    case rebounder
}

struct FieldItem: Identifiable {
    let id: UUID
    var type: ItemType
    var x, y, nx, ny: CGFloat

    init(id: UUID = UUID(), type: ItemType, x: CGFloat, y: CGFloat, nx: CGFloat, ny: CGFloat) {
        self.id = id
        self.type = type
        self.x = x; self.y = y
        self.nx = nx; self.ny = ny
    }
}
