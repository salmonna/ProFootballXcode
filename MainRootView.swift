import SwiftUI

struct MainRootView: View {

    @StateObject private var authVM = AuthViewModel()
    @State private var showSplash = true

    var body: some View {
        if showSplash {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.4)) {
                            showSplash = false
                        }
                    }
                }
        } else {
            if authVM.isLoggedIn {
                MainTabView()
            } else {
                NavigationStack {
                    LoginView(authVM: authVM)
                }
            }
        }
    }
}
