
//
//  SettingsView.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {

    @State private var showLogoutAlert = false

    var body: some View {

        ZStack {

            Color.black
                .ignoresSafeArea()

            VStack {

                VStack(alignment: .leading, spacing: 20) {

                    Text("Settings")
                        .font(.largeTitle)
                        .foregroundColor(.white)

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

                Spacer()

                Button {

                    showLogoutAlert = true

                } label: {

                    Text("Logout")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
                .padding()
            }
        }
        .alert("Logout", isPresented: $showLogoutAlert) {

            Button("Cancel", role: .cancel) { }

            Button("Logout", role: .destructive) {

                logout()
            }

        } message: {

            Text("Are you sure you want to logout?")
        }
    }

    func logout() {

        do {

            try Auth.auth().signOut()

        } catch {

            print("Logout error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
}
