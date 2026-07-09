//
//  AIService.swift
//  ProFootball
//

import Foundation

class AIService {

    private let apiURL = "http://10.32.60.96:8080/Ai/chat"

    func sendMessage(
        messages: [ChatMessage],
        completion: @escaping (ChatMessage?) -> Void
    ) {

        guard let url = URL(string: apiURL) else {
            completion(nil)
            return
        }

        let formattedMessages = messages.map { msg in
            [
                "role": msg.role,
                "text": msg.text ?? ""
            ]
        }

        let body: [String: Any] = ["messages": formattedMessages]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("❌ Network Error:", error)
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data")
                completion(nil)
                return
            }

            if let raw = String(data: data, encoding: .utf8) {
                print("📦 Raw Response:", raw)
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    completion(nil)
                    return
                }

                var reply: Any? = json["Reply"]

                // 🔥 Reply הוא String שמכיל JSON פנימי — פרסר שוב
                if let replyString = reply as? String,
                   let innerData = replyString.data(using: .utf8),
                   let innerJson = try? JSONSerialization.jsonObject(with: innerData) {
                    reply = innerJson
                }

                // טקסט רגיל
                if let text = reply as? String {
                    completion(ChatMessage(role: "model", text: text))
                    return
                }

                // Drill JSON
                if let drill = reply as? [String: Any] {
                    completion(ChatMessage(role: "model", drillJson: drill))
                    return
                }

                completion(nil)

            } catch {
                print("❌ JSON Error:", error)
                completion(nil)
            }

        }.resume()
    }
}
