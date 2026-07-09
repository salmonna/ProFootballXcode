//
//  QuizModels.swift
//  ProFootball
//
//  Created by Soli Nagosa on 03/06/2026.
//

import SwiftUI
import Foundation

// MARK: - Quiz Answer Option
struct QuizAnswerOption: Identifiable, Codable {
    var id = UUID()
    var text: String
    var isCorrect: Bool
}

// MARK: - Drawing Annotation
struct DrawingAnnotation: Identifiable, Codable {
    var id = UUID()
    var points: [CGPoint]
    var color: String  // hex string
    var lineWidth: CGFloat
    var type: AnnotationType

    enum AnnotationType: String, Codable {
        case freehand
        case circle
        case arrow
    }
}

// Codable conformance for CGPoint
extension CGPoint: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(CGFloat.self)
        let y = try container.decode(CGFloat.self)
        self.init(x: x, y: y)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
    }
}

// MARK: - Player Marker
struct PlayerMarker: Identifiable, Codable {
    var id = UUID()
    var position: CGPoint   // normalized 0–1
    var label: String       // e.g. "שחקן 9"
    var color: String       // hex
}

// MARK: - Quiz Question
struct QuizQuestion: Identifiable, Codable {
    var id = UUID()
    var timestamp: Double           // seconds in video where playback stops
    var questionText: String
    var answers: [QuizAnswerOption] // exactly 4
    var drawings: [DrawingAnnotation]
    var playerMarkers: [PlayerMarker]
    var explanation: String         // shown after answer
}

// MARK: - Football Video Quiz
struct FootballVideoQuiz: Identifiable, Codable {
    var id = UUID()
    var title: String
    var videoName: String           // local asset / URL string
    var thumbnailName: String
    var teamName: String
    var dateCreated: Date
    var questions: [QuizQuestion]
}

// MARK: - Player Quiz Result
struct PlayerQuizResult: Identifiable, Codable {
    var id = UUID()
    var playerName: String
    var quizId: UUID
    var answers: [UUID: UUID]       // questionId -> selectedAnswerId
    var score: Int
    var totalQuestions: Int
    var completedAt: Date
}

// MARK: - Sample Data
extension FootballVideoQuiz {
    static let sampleQuizzes: [FootballVideoQuiz] = [
        FootballVideoQuiz(
            id: UUID(),
            title: "בניית התקפה מהגנה",
            videoName: "sample_video",
            thumbnailName: "football_thumb",
            teamName: "צ'לסי",
            dateCreated: Date(),
            questions: [
                QuizQuestion(
                    id: UUID(),
                    timestamp: 12.0,
                    questionText: "לאן הקשר צריך לרוץ כעת?",
                    answers: [
                        QuizAnswerOption(text: "לחלל הריק מאחורי הגנה", isCorrect: true),
                        QuizAnswerOption(text: "לקבל כדור לרגל", isCorrect: false),
                        QuizAnswerOption(text: "להישאר במקום", isCorrect: false),
                        QuizAnswerOption(text: "לתמוך לאחור", isCorrect: false)
                    ],
                    drawings: [],
                    playerMarkers: [
                        PlayerMarker(position: CGPoint(x: 0.55, y: 0.4), label: "#10", color: "#FF3B30")
                    ],
                    explanation: "הקשר צריך לנצל את החלל שנפתח מאחורי הקו הגנתי."
                )
            ]
        ),
        FootballVideoQuiz(
            id: UUID(),
            title: "לחץ על מגינים",
            videoName: "sample_video2",
            thumbnailName: "football_thumb2",
            teamName: "ארסנל",
            dateCreated: Date().addingTimeInterval(-86400),
            questions: []
        )
    ]
}
