
//
//  AuthViewModel.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import Foundation
import Combine
import FirebaseAuth

class AuthViewModel: ObservableObject {

    @Published var isLoggedIn: Bool = false

    init() {
        listen()
    }

    func listen() {
        Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.isLoggedIn = user != nil
            }
        }
    }

    func login(email: String, password: String) {

        Auth.auth().signIn(withEmail: email, password: password) { result, error in

            if let error = error {
                print("Login error: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                self.isLoggedIn = true
            }
        }
    }

    func logout() {
        try? Auth.auth().signOut()

        DispatchQueue.main.async {
            self.isLoggedIn = false
        }
    }
}
