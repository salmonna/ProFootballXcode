//
//  BottomActionBar.swift
//  ProFootball
//

import SwiftUI

struct BottomActionBar: View {

    @Binding var showToolbar: Bool
    @Binding var showTrajectories: Bool
    @Binding var showArrows: Bool

    var undoAction: () -> Void
    var clearAction: () -> Void
    var createVideoAction: () -> Void

    var body: some View {

        HStack(spacing: 0) {

            actionButton(icon: "person.fill", label: "אובייקטים", color: showToolbar ? .blue : .white) {
                showToolbar.toggle()
            }

            actionButton(icon: "pencil", label: "ציור", color: showTrajectories ? .blue : .white) {
                showTrajectories.toggle()
            }

            actionButton(icon: "arrow.up.right", label: "חצים", color: showArrows ? .blue : .white) {
                showArrows.toggle()
            }

            actionButton(icon: "arrow.uturn.backward", label: "בטל", color: .white) {
                undoAction()
            }

            actionButton(icon: "trash", label: "נקה", color: .red) {
                clearAction()
            }

            actionButton(icon: "video.fill", label: "סרטון", color: .green) {
                createVideoAction()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.6))
        .cornerRadius(24)
        .padding(.horizontal, 12)
        .padding(.bottom, 16)
        .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
    }

    func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(color.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}
