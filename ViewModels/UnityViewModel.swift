//
//  UnityViewModel.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import Foundation
import UnityFramework
import Combine

class UnityViewModel: ObservableObject {
    

    func generateVideo(items: [FieldItem], trajectories: [Trajectory]) {

        let itemsJSON = items.map { item in
            """
            {"Id":"\(item.id.uuidString)","Type":"\(item.type.rawValue)","X":\(item.nx),"Y":\(item.ny)}
            """
        }.joined(separator: ",")

        let trajectoriesJSON = trajectories.map { traj in
            let pointsJSON = traj.points.map { point in
                """
                {"X":\(point.nx),"Y":\(point.ny)}
                """
            }.joined(separator: ",")
            return """
            {"Id":"\(traj.id.uuidString)","Type":"\(traj.type.rawValue)","Points":[\(pointsJSON)]}
            """
        }.joined(separator: ",")

        let jsonString = """
        {"Items":[\(itemsJSON)],"Trajectories":[\(trajectoriesJSON)]}
        """

        UnityFrameworkManager.shared.sendMessage(
            toObject: "UnityBridge",
            method: "StartSimulationFromSwift",
            message: jsonString
        )
        print("✅ JSON sent to Unity: \(jsonString)")
    }
}
