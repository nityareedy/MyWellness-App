//
//  Step_TrackerApp.swift
//  Step Tracker
//
//  Created by Nitya Reddy.
//
import SwiftUI

@main
struct StepTrackerApp: App {
    @StateObject private var hkManager = HealthKitManager()
    @State private var isShowingPermissionScreen = true

    var body: some Scene {
        WindowGroup {
            if isShowingPermissionScreen {
                HealthKitPermissionPrimingView(isShowingPermissionScreen: $isShowingPermissionScreen)
                    .environmentObject(hkManager)
            } else {
                DashboardView()
                    .environmentObject(hkManager)
            }
        }
    }
}
