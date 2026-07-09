//
//  ProfileRow.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import SwiftUI

struct ProfileRow: View {

    let label: String
    let value: String

    var body: some View {

        HStack {

            Text(label)
                .foregroundColor(.gray)

            Spacer()

            Text(value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
    }
}
