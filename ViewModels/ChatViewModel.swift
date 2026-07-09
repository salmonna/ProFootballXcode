//
//  ChatViewModel.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {

    @Published var messages: [ChatMessage] = []

    @Published var inputText = ""

    @Published var loading = false

    private let aiService = AIService()

    func sendMessage() {

        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        let userMessage = ChatMessage(
            role: "user",
            text: inputText
        )

        messages.append(userMessage)

        let currentMessages = messages

        inputText = ""

        loading = true

        aiService.sendMessage(messages: currentMessages) { response in

            DispatchQueue.main.async {

                if let response = response {

                    self.messages.append(response)
                }

                self.loading = false
            }
        }
    }
}
