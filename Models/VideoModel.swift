//
//  VideoModel.swift
//  ProFootball
//
//  Created by Soli Nagosa on 08/05/2026.
//

import Foundation

struct VideoFile: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let date: Date
}
