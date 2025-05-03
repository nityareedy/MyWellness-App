//
//  DietDashboardCard.swift
//  Step Tracker
//
//  Created by Nitya Reddy on 5/3/25.
//
import SwiftUI

struct DietDashboardCard: View {
    var body: some View {
        NavigationLink(destination: DietSuggestionView()) {
            VStack(alignment: .leading, spacing: 8) {
                Text("🍽️ Personalized Diet Plan")
                    .font(.title2.bold())
                Text("Calories & Macros based on your body data")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(16)
        }
        .padding()
    }
}

