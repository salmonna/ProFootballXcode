//
//  UserProfileViewModel.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//
import Combine
import Foundation

class UserProfileViewModel: ObservableObject {

    @Published var profile: UserProfile?
    @Published var loading = false

    private let firestoreService = FirestoreService()

    func loadProfile() {

        loading = true

        firestoreService.fetchUserProfile { profile in

            DispatchQueue.main.async {

                self.profile = profile
                self.loading = false
            }
        }
    }
}
