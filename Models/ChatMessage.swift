//
//  ChatMessage.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import Foundation

struct ChatMessage: Identifiable {

    let id = UUID()

    let role: String

    var text: String?

    var drillJson: [String: Any]?
}
