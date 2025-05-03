//
//  ExerciseSuggestionsView.swift
//  Step Tracker
//
//  Created by Nitya Reddy on 5/3/25.
//
import SwiftUI

struct ExerciseSuggestionsView: View {
    let weight: Double
    let dailyAdjustment: Double  // e.g., 400 kcal/day

    var body: some View {
        NavigationView {
            List {
                Text("Target burn: \(Int(dailyAdjustment)) kcal/day")
                    .font(.subheadline)
                    .foregroundColor(.blue)

                ForEach(exercises, id: \.name) { ex in
                    let cal15 = caloriesBurned(for: ex, minutes: 15)
                    let cal30 = caloriesBurned(for: ex, minutes: 30)

                    Section(header: Text(ex.name)) {
                        Text("15 min: ~\(cal15) kcal")
                        Text("30 min: ~\(cal30) kcal")
                        if let reps = ex.repBasedBurn(weight: weight) {
                            Text("~\(reps) reps ≈ 100 kcal")
                        }
                    }
                }
            }
            .navigationTitle("Exercises")
        }
    }

    struct Exercise {
        let name: String
        let met: Double
        let repsPer100kcal: Int?

        func repBasedBurn(weight: Double) -> String? {
            guard let reps = repsPer100kcal else { return nil }
            return "\(reps) reps ≈ 100 kcal"
        }
    }

    let exercises: [Exercise] = [
        .init(name: "Jump Rope", met: 10.0, repsPer100kcal: 850),
        .init(name: "Running (5 mph)", met: 7.0, repsPer100kcal: nil),
        .init(name: "Cycling", met: 6.0, repsPer100kcal: nil),
        .init(name: "Yoga", met: 2.5, repsPer100kcal: nil)
    ]

    func caloriesBurned(for ex: Exercise, minutes: Int) -> Int {
        let hours = Double(minutes) / 60
        return Int(ex.met * weight * hours)
    }
}


