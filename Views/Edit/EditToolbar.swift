//
//  EditToolbar.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import SwiftUI

struct EditToolbar: View {

    @Binding var selectedTool: ItemType?

    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {

            HStack(spacing: 16) {

                toolButton(.player)
                toolButton(.cone)
                toolButton(.kickWall)
                toolButton(.agilityLadder)
                toolButton(.ball)
                toolButton(.rebounder)
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .background(.black.opacity(0.4))
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }

    func toolButton(_ type: ItemType) -> some View {

        Button {
            
            // אם הכלי כבר נבחר, לחיצה נוספת תבטל אותו (nil)
            // אם לא, היא תבחר אותו
            if selectedTool == type {
                selectedTool = nil
            } else {
                selectedTool = type
            }

        } label: {

            Image(type.rawValue)
                .resizable()
                .frame(width: 28, height: 28)
                .padding()
                .background(
                    selectedTool == type
                    ? Color.blue
                    : Color.gray
                )
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        }
    }
}
