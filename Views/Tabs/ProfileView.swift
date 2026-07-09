
//
//  ProfileView.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import SwiftUI

struct ProfileView: View {

    @StateObject private var vm = UserProfileViewModel()

    var body: some View {

        ZStack {

            Color.black
                .ignoresSafeArea()

            if vm.loading {

                ProgressView()

            } else if let profile = vm.profile {

                ScrollView {

                    VStack(spacing: 20) {

                        AsyncImage(url: URL(string: profile.profileImage ?? "")) { image in

                            image
                                .resizable()
                                .scaledToFill()

                        } placeholder: {

                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())

                        Text("\(profile.firstName) \(profile.lastName)")
                            .font(.title)
                            .foregroundColor(.white)

                        VStack(spacing: 16) {

                            ProfileRow(
                                label: "Email",
                                value: profile.email
                            )

                            ProfileRow(
                                label: "Role",
                                value: profile.role
                            )

                            if let position = profile.position {

                                ProfileRow(
                                    label: "Position",
                                    value: position
                                )
                            }

                            ProfileRow(
                                label: "Age",
                                value: "\(profile.age)"
                            )

                            ProfileRow(
                                label: "Birth Date",
                                value: profile.birthDate.formatted(date: .abbreviated, time: .omitted)
                            )

                        }
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(16)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            vm.loadProfile()
        }
    }
}
