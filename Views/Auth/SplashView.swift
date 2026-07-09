//
//  SplashView.swift
//  ProFootball
//
//  Created by Soli Nagosa on 21/05/2026.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // צבע רקע — שנה לפי הצורך

            Image("ProFootballLogo") // שם הקובץ ב-Assets
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
    }
}
