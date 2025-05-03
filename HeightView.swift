//
//  HeightView.swift
//  Step Tracker
//
//  Created by Nitya Reddy on 4/28/25.
//
import SwiftUI
import HealthKit

struct HeightView: View {
    @State private var height: Double = 0.0
    @State private var heightUnit: String = "cm"
    
    private let healthStore = HKHealthStore()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Height")
                .font(.largeTitle.bold())
            
            Text("\(String(format: "%.1f", height)) \(heightUnit)")
                .font(.title2)
                .foregroundColor(.pink)
            
            Button("Fetch Height") {
                fetchHeight()
            }
            .padding()
            .background(Color.pink)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            fetchHeight()
        }
    }
    
    private func fetchHeight() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { return }
            DispatchQueue.main.async {
                let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
                self.height = heightInMeters * 100 // converting to centimeters
                self.heightUnit = "cm"
            }
        }
        
        healthStore.execute(query)
    }
}

#Preview {
    HeightView()
}
