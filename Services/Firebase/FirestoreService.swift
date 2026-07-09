//
//  FirestoreService.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreService {

    private let db = Firestore.firestore()

    func fetchUserProfile(completion: @escaping (UserProfile?) -> Void) {

        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        db.collection("users").document(uid).getDocument { snapshot, error in

            if let data = snapshot?.data() {

                let timestamp = data["birthDate"] as? Timestamp

                let profile = UserProfile(
                    firstName: data["firstName"] as? String ?? "",
                    lastName: data["lastName"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    role: data["role"] as? String ?? "",
                    position: data["position"] as? String,
                    age: data["age"] as? Int ?? 0,
                    profileImage: data["profileImage"] as? String,
                    birthDate: timestamp?.dateValue() ?? Date()
                )

                completion(profile)

            } else {
                completion(nil)
            }
        }
    }
}
