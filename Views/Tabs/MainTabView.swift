
//
//  MainTabView.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.


import SwiftUI

struct MainTabView: View {
//    @StateObject private var firebase = FirebaseManager.shared
//
//    var unreadBadge: Int {
//        firebase.messages.filter { !$0.isRead }.count
//    }

    var body: some View {
        TabView {
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }

            ChatView()
                .tabItem { Label("Chat", systemImage: "message.fill") }

            EditView()
                .tabItem { Label("Edit", systemImage: "pencil") }

            QuizView()
                .tabItem { Label("שאלונים", systemImage: "play.rectangle.on.rectangle.fill") }

//            MessagesView()
//                .tabItem { Label("הודעות", systemImage: "envelope.fill") }
//                .badge(unreadBadge > 0 ? unreadBadge : 0)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }

            VideosView()
                .tabItem { Label("Videos", systemImage: "video.fill") }
        }
//        .onAppear {
//            firebase.loadCurrentProfile()
//            firebase.listenToMessages()
//        }
    }
}
