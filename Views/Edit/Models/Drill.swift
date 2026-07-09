//
//  Drill.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//
import Foundation

struct Drill: Codable {

    var items: [DrillItem]

    var trajectories: [DrillTrajectory]

    enum CodingKeys: String, CodingKey {
        case items = "Items"
        case trajectories = "Trajectories"
    }
}

struct DrillItem: Codable {

    var id: String

    var itemType: String

    var x: Double

    var y: Double

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case itemType = "Type"
        case x = "X"
        case y = "Y"
    }
}

struct DrillTrajectory: Codable {

    var id: String

    var trajectoryType: String

    var points: [DrillPoint]

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case trajectoryType = "Type"
        case points = "Points"
    }
}

struct DrillPoint: Codable {

    var x: Double

    var y: Double

    enum CodingKeys: String, CodingKey {
        case x = "X"
        case y = "Y"
    }
}
