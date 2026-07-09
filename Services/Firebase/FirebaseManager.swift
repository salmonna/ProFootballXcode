////
////  FirebaseManager.swift
////  ProFootball
////
////  Created by Soli Nagosa on 09/06/2026.
////
//
//import Foundation
//import FirebaseFirestore
//import FirebaseStorage
//import FirebaseAuth
// 
//// MARK: - Message Model
// 
//struct TeamMessage: Identifiable, Codable {
//    @DocumentID var id: String?
//    var fromId: String
//    var fromName: String
//    var toId: String
//    var type: MessageType
//    var text: String?
//    var quizId: String?
//    var quizTitle: String?
//    var videoURL: String?
//    var timestamp: Date
//    var isRead: Bool
//    var status: MessageStatus?
// 
//    enum MessageType: String, Codable {
//        case quizAssignment = "quiz_assignment"
//        case joinRequest    = "join_request"
//        case joinApproved   = "join_approved"
//        case joinRejected   = "join_rejected"
//        case text           = "text"
//    }
// 
//    enum MessageStatus: String, Codable {
//        case pending  = "pending"
//        case approved = "approved"
//        case rejected = "rejected"
//    }
//}
// 
//// MARK: - Quiz Result Model
// 
//struct QuizResult: Identifiable, Codable {
//    @DocumentID var id: String?
//    var quizId: String
//    var playerId: String
//    var playerName: String
//    var score: Int
//    var totalQuestions: Int
//    var answers: [String: String]   // questionId -> answerId
//    var completedAt: Date
//}
// 
//// MARK: - FirebaseManager
// 
//@MainActor
//class FirebaseManager: ObservableObject {
//    static let shared = FirebaseManager()
// 
//    private let db      = Firestore.firestore()
//    private let storage = Storage.storage()
// 
//    // משתמש ב-UserProfile הקיים שלך
//    @Published var currentProfile: UserProfile?
//    @Published var currentUserId: String? { Auth.auth().currentUser?.uid }
//    @Published var teamPlayers: [String: UserProfile] = [:]   // uid -> UserProfile
//    @Published var messages: [TeamMessage] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
// 
//    private var messagesListener: ListenerRegistration?
//    private var playersListener:  ListenerRegistration?
// 
//    private init() {}
// 
//    // MARK: - Load Current User
//    // משתמש ב-FirestoreService הקיים שלך
//    func loadCurrentProfile() {
//        let service = FirestoreService()
//        service.fetchUserProfile { [weak self] profile in
//            DispatchQueue.main.async {
//                self?.currentProfile = profile
//                // אחרי טעינת הפרופיל — טען שחקנים אם מאמן
//                if profile?.role == "coach" {
//                    self?.loadTeamPlayers()
//                }
//            }
//        }
//    }
// 
//    var isCoach: Bool { currentProfile?.role == "coach" }
//    var currentUserName: String {
//        guard let p = currentProfile else { return "" }
//        return "\(p.firstName) \(p.lastName)"
//    }
// 
//    // MARK: - Team Players
//    private func loadTeamPlayers() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
// 
//        playersListener?.remove()
//        // שחקנים שהמאמן שלהם הוא ה-uid הנוכחי
//        playersListener = db.collection("users")
//            .whereField("coachId", isEqualTo: uid)
//            .whereField("role", isEqualTo: "player")
//            .addSnapshotListener { [weak self] snap, _ in
//                guard let self, let snap else { return }
//                var result: [String: UserProfile] = [:]
//                for doc in snap.documents {
//                    let data = doc.data()
//                    let ts = data["birthDate"] as? Timestamp
//                    let profile = UserProfile(
//                        firstName:    data["firstName"]   as? String ?? "",
//                        lastName:     data["lastName"]    as? String ?? "",
//                        email:        data["email"]       as? String ?? "",
//                        role:         data["role"]        as? String ?? "",
//                        position:     data["position"]    as? String,
//                        age:          data["age"]         as? Int    ?? 0,
//                        profileImage: data["profileImage"] as? String,
//                        birthDate:    ts?.dateValue()     ?? Date()
//                    )
//                    result[doc.documentID] = profile
//                }
//                self.teamPlayers = result
//            }
//    }
// 
//    // MARK: - Messages Listener
//    func listenToMessages() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        messagesListener?.remove()
//        messagesListener = db.collection("messages")
//            .whereField("toId", isEqualTo: uid)
//            .order(by: "timestamp", descending: true)
//            .addSnapshotListener { [weak self] snap, error in
//                guard let self, let snap else { return }
//                self.messages = (try? snap.documents.compactMap {
//                    try $0.data(as: TeamMessage.self)
//                }) ?? []
//            }
//    }
// 
//    func markAsRead(messageId: String) {
//        db.collection("messages").document(messageId)
//            .updateData(["isRead": true])
//    }
// 
//    // MARK: - Send Quiz Assignment
//    func sendQuizAssignment(
//        quiz: FootballVideoQuiz,
//        toUid: String,
//        toName: String,
//        onProgress: @escaping (Double) -> Void
//    ) async throws {
//        guard let fromUid = Auth.auth().currentUser?.uid else {
//            throw NSError(domain: "Auth", code: 401)
//        }
// 
//        // 1. העלה סרטון ל-Storage אם נתיב מקומי
//        let videoURL: String
//        if quiz.videoName.hasPrefix("/") {
//            videoURL = try await uploadVideo(
//                localPath: quiz.videoName,
//                quizId: quiz.id.uuidString,
//                onProgress: onProgress
//            )
//        } else {
//            videoURL = quiz.videoName
//            onProgress(1.0)
//        }
// 
//        // 2. שמור quiz ב-Firestore
//        let quizData: [String: Any] = [
//            "id":          quiz.id.uuidString,
//            "title":       quiz.title,
//            "teamName":    quiz.teamName,
//            "videoURL":    videoURL,
//            "createdBy":   fromUid,
//            "dateCreated": Timestamp(date: quiz.dateCreated),
//            "questions":   encodeQuestions(quiz.questions)
//        ]
//        try await db.collection("quizzes")
//            .document(quiz.id.uuidString)
//            .setData(quizData)
// 
//        // 3. שלח הודעה
//        let msg = TeamMessage(
//            fromId:     fromUid,
//            fromName:   currentUserName,
//            toId:       toUid,
//            type:       .quizAssignment,
//            quizId:     quiz.id.uuidString,
//            quizTitle:  quiz.title,
//            videoURL:   videoURL,
//            timestamp:  Date(),
//            isRead:     false
//        )
//        try db.collection("messages").addDocument(from: msg)
//    }
// 
//    // MARK: - Send Join Request (שחקן → מאמן)
//    func sendJoinRequest(toCoachUid: String, toCoachName: String) async throws {
//        guard let fromUid = Auth.auth().currentUser?.uid else {
//            throw NSError(domain: "Auth", code: 401)
//        }
//        let msg = TeamMessage(
//            fromId:    fromUid,
//            fromName:  currentUserName,
//            toId:      toCoachUid,
//            type:      .joinRequest,
//            timestamp: Date(),
//            isRead:    false,
//            status:    .pending
//        )
//        try db.collection("messages").addDocument(from: msg)
//    }
// 
//    // MARK: - Respond to Join Request (מאמן → שחקן)
//    func respondToJoinRequest(message: TeamMessage, approve: Bool) async throws {
//        guard let msgId = message.id,
//              let coachUid = Auth.auth().currentUser?.uid else { return }
// 
//        // עדכן סטטוס
//        try await db.collection("messages").document(msgId).updateData([
//            "status": approve ? "approved" : "rejected",
//            "isRead": true
//        ])
// 
//        if approve {
//            // הוסף coachId לשחקן
//            try await db.collection("users").document(message.fromId).updateData([
//                "coachId": coachUid
//            ])
// 
//            // שלח הודעת אישור לשחקן
//            let reply = TeamMessage(
//                fromId:    coachUid,
//                fromName:  currentUserName,
//                toId:      message.fromId,
//                type:      .joinApproved,
//                text:      "ברוך הבא לקבוצה! 🎉",
//                timestamp: Date(),
//                isRead:    false
//            )
//            try db.collection("messages").addDocument(from: reply)
//        }
//    }
// 
//    // MARK: - Save Quiz Result
//    func saveQuizResult(
//        quizId: String,
//        score: Int,
//        total: Int,
//        answers: [UUID: UUID]
//    ) async throws {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let stringAnswers = Dictionary(
//            uniqueKeysWithValues: answers.map { ($0.key.uuidString, $0.value.uuidString) }
//        )
//        let result = QuizResult(
//            quizId:         quizId,
//            playerId:       uid,
//            playerName:     currentUserName,
//            score:          score,
//            totalQuestions: total,
//            answers:        stringAnswers,
//            completedAt:    Date()
//        )
//        try db.collection("quiz_results").addDocument(from: result)
//    }
// 
//    // MARK: - Search Coach by Email (לשחקן)
//    func searchCoach(byEmail email: String) async throws -> (uid: String, profile: UserProfile)? {
//        let snap = try await db.collection("users")
//            .whereField("email",  isEqualTo: email.lowercased())
//            .whereField("role",   isEqualTo: "coach")
//            .getDocuments()
// 
//        guard let doc = snap.documents.first else { return nil }
//        let data = doc.data()
//        let ts = data["birthDate"] as? Timestamp
//        let profile = UserProfile(
//            firstName:    data["firstName"]    as? String ?? "",
//            lastName:     data["lastName"]     as? String ?? "",
//            email:        data["email"]        as? String ?? "",
//            role:         data["role"]         as? String ?? "",
//            position:     data["position"]     as? String,
//            age:          data["age"]          as? Int    ?? 0,
//            profileImage: data["profileImage"] as? String,
//            birthDate:    ts?.dateValue()      ?? Date()
//        )
//        return (uid: doc.documentID, profile: profile)
//    }
// 
//    // MARK: - Storage Upload
//    func uploadVideo(
//        localPath: String,
//        quizId: String,
//        onProgress: @escaping (Double) -> Void
//    ) async throws -> String {
//        let localURL = URL(fileURLWithPath: localPath)
//        guard FileManager.default.fileExists(atPath: localPath) else {
//            throw NSError(domain: "ProFootball", code: 404,
//                          userInfo: [NSLocalizedDescriptionKey: "קובץ לא נמצא: \(localPath)"])
//        }
// 
//        let ref = storage.reference()
//            .child("videos/\(quizId)/\(UUID().uuidString).mp4")
// 
//        let metadata = StorageMetadata()
//        metadata.contentType = "video/mp4"
// 
//        return try await withCheckedThrowingContinuation { continuation in
//            let task = ref.putFile(from: localURL, metadata: metadata)
// 
//            task.observe(.progress) { snapshot in
//                let done  = Double(snapshot.progress?.completedUnitCount ?? 0)
//                let total = Double(snapshot.progress?.totalUnitCount ?? 1)
//                DispatchQueue.main.async { onProgress(total > 0 ? done / total : 0) }
//            }
//            task.observe(.success) { _ in
//                ref.downloadURL { url, error in
//                    if let url {
//                        continuation.resume(returning: url.absoluteString)
//                    } else {
//                        continuation.resume(throwing: error ?? NSError(domain: "Storage", code: -1))
//                    }
//                }
//            }
//            task.observe(.failure) { snapshot in
//                continuation.resume(
//                    throwing: snapshot.error ?? NSError(domain: "Storage", code: -1)
//                )
//            }
//        }
//    }
// 
//    // MARK: - Cleanup
//    func stopListening() {
//        messagesListener?.remove()
//        playersListener?.remove()
//    }
// 
//    // MARK: - Encode Questions for Firestore
//    private func encodeQuestions(_ questions: [QuizQuestion]) -> [[String: Any]] {
//        questions.map { q in [
//            "id":           q.id.uuidString,
//            "timestamp":    q.timestamp,
//            "questionText": q.questionText,
//            "explanation":  q.explanation,
//            "answers": q.answers.map { a in
//                ["id": a.id.uuidString, "text": a.text, "isCorrect": a.isCorrect]
//            },
//            "playerMarkers": q.playerMarkers.map { m in
//                ["id": m.id.uuidString, "label": m.label,
//                 "color": m.color, "x": m.position.x, "y": m.position.y]
//            }
//        ]}
//    }
//}
