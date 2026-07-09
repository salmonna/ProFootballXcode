//
//  TrajectoriesBar.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import SwiftUI

struct TrajectoriesBar: View {

    @Binding var selectedTrajectory: TrajectoryType?

    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {

            HStack(spacing: 16) {

                trajectoryButton(.run)
                trajectoryButton(.dribble)
                trajectoryButton(.highKnees)
            }
            .padding()
        }
        .background(Color(.darkGray))
    }

    func trajectoryButton(_ type: TrajectoryType) -> some View {

        Button {

            // לוגיקה של ביטול בחירה בלחיצה שנייה
            if selectedTrajectory == type {
                selectedTrajectory = nil
            } else {
                selectedTrajectory = type
            }

        } label: {

            Text(type.rawValue)

                .foregroundColor(.white)

                .padding()

                .background(
                    selectedTrajectory == type
                    ? Color.blue
                    : Color.gray
                )
                .cornerRadius(12)
        }
    }
}
