//
//  HeartRateView.swift
//  Step Tracker
//
//  Created by Nitya Reddy on 4/25/25.
//

import SwiftUI

struct HeartRateView: View {
    @State private var heartRates: [HealthMetric] = []
    let healthKitManager = HealthKitManager()

    var body: some View {
        List(heartRates, id: \.date) { metric in
            VStack(alignment: .leading) {
                Text(metric.date, style: .date)
                Text("Heart Rate: \(Int(metric.value)) bpm")
            }
        }
        .navigationTitle("Heart Rate")
        .task {
            do {
                heartRates = try await healthKitManager.fetchHeartRate()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
