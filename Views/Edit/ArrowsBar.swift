//
//  ArrowsBar.swift
//  ProFootball
//
//  Created by Soli Nagosa on 10/05/2026.
//

//
//  ArrowsBar.swift
//  ProFootball
//

import SwiftUI

struct ArrowsBar: View {
    @Binding var selectedTrajectory: TrajectoryType?

    var body: some View {
        HStack(spacing: 16) {
            arrowButton(.pass, icon: "arrow.right.circle.fill", label: "פס")
            arrowButton(.shoot, icon: "arrow.up.right.circle.fill", label: "בעיטה")
            arrowButton(.slalomSideToSide, icon: "arrow.left.arrow.right.circle.fill", label: "סלאלום צדדי")
            arrowButton(.slalomRightLeg, icon: "arrow.turn.up.right", label: "סלאלום רגל ימין")
            arrowButton(.slalomSole, icon: "arrow.down.right.circle.fill", label: "סלאלום סוליה")
            arrowButton(.passingRebounderNonStop, icon: "arrow.down.right.circle.fill", label: "פס ריבאונדר ללא עצירה")
            arrowButton(.passingRebounderPullFalsh, icon: "arrow.down.right.circle.fill", label: "פס ריבאונדר פאלש")
            arrowButton(.passingRebounderPullPass, icon: "arrow.down.right.circle.fill", label: "פס ריבאונדר משיכה מסירה")
            arrowButton(.controllSolePass, icon: "figure.soccer", label: "שליטה סוליה פס")
            arrowButton(.controllSideToSide, icon: "arrow.left.arrow.right", label: "שליטה צדדית")
            arrowButton(.controllSole, icon: "shoe.fill", label: "שליטה סוליה")
        }
        .padding()
        .background(Color(.darkGray))
    }

    func arrowButton(_ type: TrajectoryType, icon: String, label: String) -> some View {
        Button {
            selectedTrajectory = selectedTrajectory == type ? nil : type
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .padding()
            .background(selectedTrajectory == type ? Color.blue : Color.gray)
            .cornerRadius(12)
        }
    }
}
