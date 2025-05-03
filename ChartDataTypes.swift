//
//  ChartDataTypes.swift
//  Step Tracker
//
//  Created by Nitya Reddy on 4/26/25.
//
import Foundation

struct DateValueChartData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

extension Array where Element == DateValueChartData {
    
    var avgStepCount: Double {
        guard self.isEmpty == false else { return 0 }
        let totalSteps = self.map(\.value).reduce(0, +)
        return totalSteps / Double(self.count)
    }
    
    func selectedData(in date: Date?) -> DateValueChartData? {
        guard let date else { return nil }
        return self.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    var minValue: Double {
        self.map(\.value).min() ?? 0
    }
    
    var average: Double {
        self.reduce(0) { $0 + $1.value } / Double(self.count)
    }
}
