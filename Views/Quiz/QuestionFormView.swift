//
//  QuestionFormView.swift
//  ProFootball
//
//  Created by Soli Nagosa on 03/06/2026.
//

import SwiftUI

struct QuestionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State var question: QuizQuestion
    let drawings: [DrawingAnnotation]
    let markers: [PlayerMarker]
    let timestamp: Double
    let onSave: (QuizQuestion) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0A0E1A").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Timestamp badge
                        HStack {
                            Label("זמן עצירה: \(formatTime(timestamp))", systemImage: "clock.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "#FFB340"))
                            Spacer()
                            Label("\(drawings.count) ציורים • \(markers.count) שחקנים", systemImage: "paintbrush.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#00D4AA"))
                        }
                        .padding(14)
                        .background(Color(hex: "#12172A"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Question text
                        VStack(alignment: .leading, spacing: 8) {
                            Label("השאלה", systemImage: "questionmark.bubble.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B7A99"))

                            TextField("לאן הקשר צריך לרוץ כעת?", text: $question.questionText, axis: .vertical)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(14)
                                .background(Color(hex: "#12172A"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .lineLimit(3...6)
                        }

                        // Answer options
                        VStack(alignment: .leading, spacing: 10) {
                            Label("תשובות (סמן את הנכונה)", systemImage: "list.bullet.circle.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B7A99"))

                            ForEach(question.answers.indices, id: \.self) { i in
                                AnswerOptionRow(
                                    index: i,
                                    answer: $question.answers[i],
                                    onSelectCorrect: {
                                        for j in question.answers.indices {
                                            question.answers[j].isCorrect = (j == i)
                                        }
                                    }
                                )
                            }
                        }

                        // Explanation
                        VStack(alignment: .leading, spacing: 8) {
                            Label("הסבר (מוצג אחרי תשובה)", systemImage: "lightbulb.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B7A99"))

                            TextField("הסבר מדוע זוהי התשובה הנכונה...", text: $question.explanation, axis: .vertical)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .padding(14)
                                .background(Color(hex: "#12172A"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .lineLimit(2...4)
                        }

                        // Save button
                        Button {
                            var saved = question
                            saved.drawings = drawings
                            saved.playerMarkers = markers
                            saved.timestamp = timestamp
                            onSave(saved)
                            dismiss()
                        } label: {
                            Text("שמור שאלה")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    question.questionText.isEmpty ? Color(hex: "#2A3450") : Color(hex: "#00D4AA")
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(question.questionText.isEmpty)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("עריכת שאלה")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ביטול") { dismiss() }
                        .foregroundColor(Color(hex: "#6B7A99"))
                }
            }
        }
    }

    private func formatTime(_ t: Double) -> String {
        let m = Int(t) / 60; let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Answer Option Row
struct AnswerOptionRow: View {
    let index: Int
    @Binding var answer: QuizAnswerOption
    let onSelectCorrect: () -> Void

    private let letters = ["א", "ב", "ג", "ד"]
    private let colors  = ["#00D4AA", "#0A84FF", "#FFB340", "#BF5AF2"]

    var body: some View {
        HStack(spacing: 12) {
            // Correct toggle
            Button(action: onSelectCorrect) {
                ZStack {
                    Circle()
                        .fill(answer.isCorrect ? Color(hex: colors[index]) : Color(hex: "#1A2035"))
                        .frame(width: 32, height: 32)
                    Text(letters[index])
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(answer.isCorrect ? .black : Color(hex: "#6B7A99"))
                }
            }

            TextField("תשובה \(letters[index])", text: $answer.text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)

            if answer.isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "#00D4AA"))
                    .font(.system(size: 18))
            }
        }
        .padding(12)
        .background(
            answer.isCorrect
                ? Color(hex: colors[index]).opacity(0.12)
                : Color(hex: "#12172A")
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(answer.isCorrect ? Color(hex: colors[index]).opacity(0.5) : Color(hex: "#1E2840"), lineWidth: 1)
        )
        .animation(.spring(response: 0.25), value: answer.isCorrect)
    }
}
