// LoginView.swift

import SwiftUI

struct LoginView: View {

    @ObservedObject var authVM: AuthViewModel

    @State private var email = ""
    @State private var password = ""

    var body: some View {

        NavigationStack {
            VStack(spacing: 20) {

                Text("Login")
                    .font(.largeTitle)
                    .foregroundColor(.white)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                Button("Login") {
                    authVM.login(email: email, password: password)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                NavigationLink("אין לך חשבון? הירשם") {
                    RegisterView()
                }
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color.black)
        }
    }
}
