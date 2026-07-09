//
//  ChatBubble.swift
//  ProFootball
//

import SwiftUI

struct ChatBubble: View {

    let message: ChatMessage

    var body: some View {

        HStack {

            if message.role == "user" { Spacer() }

            VStack(alignment: .leading, spacing: 8) {

                // 🧠 טקסט רגיל
                if let text = message.text {
                    Text(text)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            message.role == "user"
                                ? Color.blue
                                : Color(.darkGray)
                        )
                        .cornerRadius(16)
                }

                // ⚽ Drill — כפתור ניווט
                if let drill = message.drillJson {
                    VStack(alignment: .leading, spacing: 8) {

                        Text("⚽ נוצר אימון חדש!")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color(.darkGray))
                            .cornerRadius(16)

                        NavigationLink(destination: EditView(drillJson: drill)) {
                            HStack {
                                Image(systemName: "sportscourt.fill")
                                Text("טען למגרש")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                }
            }

            if message.role == "model" { Spacer() }
        }
    }
}
