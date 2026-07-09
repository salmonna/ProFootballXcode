//
//  ProFootballApp.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import FirebaseCore
import SwiftUI

@main
struct ProFootballApp: App {
    
    init() {
        // Firebase חייב לעלות מיד
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainRootView()
                .onAppear {
                    // נותנים ל-UI חצי שנייה להתייצב לפני שיוניטי נטענת
                    // זה פותר את שגיאת ה-MTLTextureDescriptor width of zero
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        UnityFrameworkManager.shared.initUnity()
                    }
                }
        }
    }
}
