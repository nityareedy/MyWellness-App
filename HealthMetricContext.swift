//
//  HealthMetricContext.swift
//  Step Tracker
//
//  Created by Nitya Reddy on 4/26/25.
//
import SwiftUI

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight, height, heartRate, sleep

    var id: Self { self }

    var title: String {
        switch self {
        case .steps: return "Steps"
        case .weight: return "Weight"
        case .height: return "Height"
        case .heartRate: return "Heart"
        case .sleep: return "Sleep"
        }
    }

    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .weight: return "scalemass"
        case .height: return "ruler.fill"   
        case .heartRate: return "heart.fill"
        case .sleep: return "bed.double.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .steps: return .pink
        case .weight: return .green
        case .height: return .indigo
        case .heartRate: return .red
        case .sleep: return .blue
        }
    }

    var fractionLength: Int {
        switch self {
        case .steps: return 0
        case .weight: return 1
        default: return 0
        }
    }
}
