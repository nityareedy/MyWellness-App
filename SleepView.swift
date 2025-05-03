//
//  SleepView.swift
//  Step Tracker
//
//  Created by Nitya Reddy on 4/25/25.
//

import SwiftUI

struct SleepView: View {
    @State private var sleepData: [HealthMetric] = []
    let healthKitManager = HealthKitManager()

    var body: some View {
        List(sleepData, id: \.date) { metric in
            VStack(alignment: .leading) {
                Text("Sleep Start: \(metric.date.formatted(date: .long, time: .shortened))")
                Text("Sleep Quality: \(Int(metric.value)) (Raw Value)")
            }
        }
        .navigationTitle("Sleep Tracking")
        .task {
            do {
                sleepData = try await healthKitManager.fetchSleepData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
