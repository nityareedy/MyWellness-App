//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Nitya Reddy Yerram
import SwiftUI
import Charts

struct DashboardView: View {
    
    @EnvironmentObject var hkManager: HealthKitManager
    
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var selectedMetric: DateValueChartData? = nil
    @State private var isPulsingHeart: Bool = false
    private let heartRateGoal = 100.0
    
    var body: some View {
        NavigationStack{
                ScrollView {
                    VStack(spacing: 24) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(HealthMetricContext.allCases) { stat in
                                VStack(spacing: 4) {
                                    Image(systemName: stat.icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 22, height: 22) // Ensures equal size for all icons
                                    Text(stat.title)
                                        .font(.caption2)
                                }
                                .frame(width: 64, height: 64)
                                .foregroundColor(selectedStat == stat ? .white : .gray)
                                .background(selectedStat == stat ? stat.tintColor : Color.gray.opacity(0.2))
                                .cornerRadius(12)
                                .onTapGesture {
                                    selectedStat = stat
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Dashboards based on selection
                    switch selectedStat {
                    case .steps: stepsDashboard
                    case .weight: weightDashboard
                    case .heartRate: heartRateDashboard
                    case .sleep: sleepDashboard
                    case .height: heightDashboard
                    }
                }
                .padding(.top)
            }
            NavigationLink(destination: DietSuggestionView()) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                            .padding()
                    }
            .navigationTitle("Nitya’s Health Tracker")
            .task {
                await loadHealthData()
                if selectedMetric == nil {
                    selectedMetric = hkManager.steps.averageWeekdayCountData.first(where: {
                        Calendar.current.component(.weekday, from: $0.date) ==
                        Calendar.current.component(.weekday, from: Date())
                    })
                }
                let avgHeartRate = averageHeartRate()
                isPulsingHeart = avgHeartRate > 100
            }
        }
    }
    
    private func loadHealthData() async {
        do {
            hkManager.steps = try await hkManager.fetchStepCount()
            hkManager.weights = try await hkManager.fetchWeights()
            hkManager.heights = try await hkManager.fetchHeightData()
            hkManager.heartRates = try await hkManager.fetchHeartRate()
            hkManager.sleepData = try await hkManager.fetchSleepData()
        } catch {
            print("Error loading health data: \(error)")
        }
    }
    
    // MARK: - Steps Dashboard
    private var stepsDashboard: some View {
        VStack(spacing: 20) {
            if hkManager.steps.isEmpty {
                emptyCard(title: "Steps")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("👣 Steps")
                        .font(.title2.bold())
                    Text("Avg: \(averageSteps()) Steps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(stepChangeTip())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                stepsBarChart
                averagesDonutChart
            }
        }
        .padding()
    }
    
    private var stepsBarChart: some View {
        Chart(hkManager.steps.chartData) { metric in
            BarMark(
                x: .value("Date", metric.date, unit: .day),
                y: .value("Steps", metric.value)
            )
            .foregroundStyle(.pink.gradient)
        }
        .frame(height: 180)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var averagesDonutChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Averages")
                .font(.title3.bold())
                .foregroundColor(.pink)
            
            Text("Last 28 days")
                .font(.caption)
                .foregroundColor(.secondary)
            
            let donutData = angles(for: hkManager.steps.averageWeekdayCountData)
            
            ZStack {
                Chart {
                    ForEach(donutData, id: \.metric.date) { item in
                        SectorMark(
                            angle: .value("Steps", item.metric.value)
                        )
                        .foregroundStyle(.pink.gradient)
                        .cornerRadius(8)
                        .opacity(selectedMetric?.date == item.metric.date ? 1.0 : 0.7)
                    }
                }
                .frame(width: 220, height: 220)
                .padding(30)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .id(selectedMetric?.date)
                
                ForEach(donutData, id: \.metric.date) { item in
                    Button {
                        selectedMetric = item.metric
                    } label: {
                        Color.clear
                    }
                    .frame(width: 220, height: 220)
                    .contentShape(DonutSliceShape(startAngle: item.start, endAngle: item.end))
                }
                
                VStack {
                    if let selected = selectedMetric {
                        Text(weekdayString(from: selected.date))
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        Text("\(Int(selected.value))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Tap a day")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Weight Dashboard
    private var weightDashboard: some View {
        VStack(spacing: 20) {
            if hkManager.weights.isEmpty {
                emptyCard(title: "Weight")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🏋️‍♂️ Weight")
                        .font(.title2.bold())
                    Text("Avg: \(averageWeight()) lbs (last 28 days)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Min: \(minWeight()) lbs")
                        Spacer()
                        Text("Max: \(maxWeight()) lbs")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text(weightTip())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                weightBarChart
            }
        }
        .padding()
    }
    
    private var weightBarChart: some View {
        Chart {
            ForEach(Array(hkManager.weights.chartData.enumerated()), id: \.1.date) { index, metric in
                BarMark(
                    x: .value("Date", metric.date, unit: .day),
                    y: .value("Weight", metric.value)
                )
                .foregroundStyle(colorForWeight(at: index))
                .annotation(position: .top) {
                    Text(String(format: "%.0f", metric.value))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                }
            }
        }
        .frame(height: 180)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .padding(.vertical)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .transition(.scale)
        .animation(.easeOut(duration: 0.6), value: hkManager.weights.count)
    }
    
    private func colorForWeight(at index: Int) -> Color {
        let weights = hkManager.weights
        guard index > 0 else {
            return .purple
        }
        
        let today = weights[index].value
        let yesterday = weights[index - 1].value
        
        if today < yesterday {
            return .red
        } else if today > yesterday {
            return .green
        } else {
            return .purple
        }
    }
    // MARK: - Heart Rate Dashboard
    private var heartRateDashboard: some View {
        VStack(spacing: 20) {
            if hkManager.heartRates.isEmpty {
                emptyCard(title: "Heart Rate")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("❤️ Heart Rate")
                        .font(.title2.bold())
                        .scaleEffect(isPulsingHeart ? 1.2 : 1.0)
                        .animation(isPulsingHeart ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isPulsingHeart)
                    
                    Text("Avg: \(averageHeartRate()) BPM (last 28 days)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Min: \(minHeartRate()) BPM")
                        Spacer()
                        Text("Max: \(maxHeartRate()) BPM")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text(heartRateTip())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(healthAdviceTip())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: heartRateGoalProgress(), total: 100)
                            .accentColor(.red)
                        
                        Text("Goal: Average HR ≤ \(Int(heartRateGoal)) BPM")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
                
                heartRateLineChart
            }
        }
        .padding()
    }
    
    private var heartRateLineChart: some View {
        Chart(hkManager.heartRates.chartData) { metric in
            LineMark(
                x: .value("Date", metric.date, unit: .day),
                y: .value("Heart Rate", metric.value)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(.red.gradient)
            .lineStyle(StrokeStyle(lineWidth: 3))
            .symbol(Circle())
            .symbolSize(30)
        }
        .frame(height: 220)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    private var sleepDashboard: some View {
        VStack(spacing: 20) {
            if hkManager.sleepData.isEmpty {
                emptyCard(title: "Sleep")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("😴 Sleep")
                        .font(.title2.bold())
                    
                    Text("Avg: \(averageSleep()) hrs (last 28 days)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Min: \(minSleep()) hrs")
                        Spacer()
                        Text("Max: \(maxSleep()) hrs")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text(sleepTip())
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                sleepBarChart
                sleepLast7DaysChart
            }
        }
        .padding()
    }
    
    private var sleepBarChart: some View {
        Chart(hkManager.sleepData) { metric in
            BarMark(
                x: .value("Date", metric.date, unit: .day),
                y: .value("Hours Slept", metric.value)
            )
            .foregroundStyle(.cyan.gradient)
        }
        .frame(height: 200)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.vertical)
    }
    
    private var sleepLast7DaysChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last 7 Days Sleep")
                .font(.title3.bold())
                .foregroundColor(.blue)
            
            last7DaysChartView(data: last7DaysSleepData)
        }
    }
    
    private func last7DaysChartView(data: [HealthMetric]) -> some View {
        Chart {
            ForEach(data, id: \..date) { sleep in
                BarMark(
                    x: .value("Date", sleep.date, unit: .day),
                    y: .value("Hours Slept", sleep.value)
                )
                .foregroundStyle(sleep.value < 6 ? Color.red.gradient : Color.blue.gradient)
                .annotation(position: .top) {
                    Text("\(String(format: "%.1f", sleep.value))h")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                }
            }
        }
        .frame(height: 200)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var last7DaysSleepData: [HealthMetric] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let filtered = hkManager.sleepData.filter { $0.date >= oneWeekAgo }
        print("💤 Filtered Last 7 Days Sleep Data Count: \(filtered.count)")
        for sleep in filtered {
            print("Date: \(sleep.date), Hours Slept: \(sleep.value)")
        }
        return filtered
    }
    
    // MARK: - Other Views
    private func metricList(title: String, data: [HealthMetric]) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if data.isEmpty {
                emptyCard(title: title)
            } else {
                ForEach(data, id: \.date) { metric in
                    HStack {
                        Text(metric.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f", metric.value))
                            .bold()
                    }
                    .padding(.vertical, 4)
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }
    
    private func emptyCard(title: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title3)
                .foregroundColor(.purple)
            
            Divider().overlay(Color.cyan)
            
            VStack(spacing: 4) {
                Image(systemName: "chart.bar.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                Text("No Data")
                    .bold()
                Text("There is no \(title.lowercased()) data found in Health app.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private var heightDashboard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📏 Height")
                .font(.title2.bold())
            
            if let latest = hkManager.heights.sorted(by: { $0.date > $1.date }).first {
                let latestInches = latest.value * 39.3701
                let feet = Int(latestInches / 12)
                let inches = Int(latestInches.truncatingRemainder(dividingBy: 12))
                
                Text("\(feet)′\(inches)″")
                    .font(.title)
                    .padding(.bottom, 1)
                
                if hkManager.heights.count >= 2 {
                    let sortedHeights = hkManager.heights.sorted(by: { $0.date > $1.date })
                    let delta = sortedHeights[0].value - sortedHeights[1].value
                    Text(
                        delta > 0.01 ? "⬆️ Increased" :
                            delta < -0.01 ? "⬇️ Decreased" :
                            "➡️ Same"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                let avgHeight = hkManager.heights.suffix(28).map(\.value).reduce(0, +) / Double(max(hkManager.heights.suffix(28).count, 1))
                let avgInches = avgHeight * 39.3701
                let avgFeet = Int(avgInches / 12)
                let avgInch = Int(avgInches.truncatingRemainder(dividingBy: 12))
                
                Text("Avg (28d): \(avgFeet)′\(avgInch)″")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                let uniqueHeights = Set(hkManager.heights.suffix(28).map { Int($0.value * 39.3701) })
                let consistencyScore = 100 - (uniqueHeights.count * 5)
                Text("Consistency Score: \(consistencyScore)%")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            
            if hkManager.heights.isEmpty {
                emptyCard(title: "Height")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(hkManager.heights.sorted(by: { $0.date > $1.date })) { entry in
                            let inches = entry.value * 39.3701
                            let ft = Int(inches / 12)
                            let inch = Int(inches.truncatingRemainder(dividingBy: 12))
                            
                            VStack(spacing: 6) {
                                Text("\(ft)′\(inch)″")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(entry.date, style: .date)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .frame(width: 90)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.purple, .indigo]),
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 📝 Tip Text
                Text("📝 Tip: Regular posture checks help maintain consistent height readings.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
        }
        .padding()
    }
    
    // MARK: - Helper functions
    private func getData(for context: HealthMetricContext) -> [HealthMetric] {
        switch context {
        case .steps: return hkManager.steps
        case .weight: return hkManager.weights
        case .height: return []
        case .heartRate: return hkManager.heartRates
        case .sleep: return hkManager.sleepData
        }
    }
    
    private func averageSteps() -> Int {
        let total = hkManager.steps.map(\.value).reduce(0, +)
        return Int(total / Double(max(hkManager.steps.count, 1)))
    }
    
    private func averageWeight() -> Int {
        let total = hkManager.weights.suffix(28).map(\.value).reduce(0, +)
        return Int(total / Double(max(hkManager.weights.suffix(28).count, 1)))
    }
    
    private func averageHeartRate() -> Int {
        let total = hkManager.heartRates.suffix(28).map(\.value).reduce(0, +)
        return Int(total / Double(max(hkManager.heartRates.suffix(28).count, 1)))
    }
    
    private func minWeight() -> Int {
        hkManager.weights.suffix(28).map(\.value).min().map(Int.init) ?? 0
    }
    
    private func maxWeight() -> Int {
        hkManager.weights.suffix(28).map(\.value).max().map(Int.init) ?? 0
    }
    
    private func minHeartRate() -> Int {
        hkManager.heartRates.suffix(28).map(\.value).min().map(Int.init) ?? 0
    }
    
    private func maxHeartRate() -> Int {
        hkManager.heartRates.suffix(28).map(\.value).max().map(Int.init) ?? 0
    }
    
    private func stepChangeTip() -> String {
        let last28 = hkManager.steps.suffix(28)
        guard last28.count >= 2 else { return "" }
        let diff = Int((last28.last?.value ?? 0) - (last28.first?.value ?? 0))
        
        if diff > 500 {
            return "🚀 Great momentum! Keep going!"
        } else if diff < -500 {
            return "🏃 Stay active daily!"
        } else {
            return "💪 Consistency is power!"
        }
    }
    
    private func weightTip() -> String {
        let last28 = hkManager.weights.suffix(28)
        guard last28.count >= 2 else { return "" }
        let diff = Int((last28.last?.value ?? 0) - (last28.first?.value ?? 0))
        
        if diff > 0 {
            return "🏋️‍♂️ Building strength!"
        } else if diff < 0 {
            return "🎯 Fitness progress!"
        } else {
            return "😌 Stable and steady!"
        }
    }
    
    private func heightStabilityTip() -> String {
        let last28 = hkManager.heights.suffix(28).map(\.value)
        guard let min = last28.min(), let max = last28.max() else { return "" }
        let diff = max - min
        if diff < 0.01 {
            return "📏 Stable height over the last month"
        } else {
            return "⚠️ Height data fluctuates slightly"
        }
    }
    
    private func heartRateGoalProgress() -> Double {
        let avg = averageHeartRate()
        return min(100, (heartRateGoal / Double(avg)) * 100)
    }
    
    private func heartRateTip() -> String {
        let avg = averageHeartRate()
        if avg >= 100 {
            return "⚡ High HR – Consider Relaxation"
        } else if avg < 60 {
            return "🏃‍♂️ Excellent Cardio Health"
        } else {
            return "💓 Normal Range"
        }
    }
    
    private func healthAdviceTip() -> String {
        let avg = averageHeartRate()
        if avg > 100 {
            return "🧘 Relax and rest more!"
        } else if avg > 85 {
            return "💧 Stay hydrated!"
        } else if avg > 70 {
            return "🏃‍♂️ Great! Add light cardio!"
        } else {
            return "💚 Excellent cardiovascular health!"
        }
    }
    private func averageSleepHours() -> Int {
        let total = hkManager.sleepData.suffix(28).map(\.value).reduce(0, +)
        return Int(total / Double(max(hkManager.sleepData.suffix(28).count, 1)))
    }
    
    private func minSleepHours() -> Int {
        hkManager.sleepData.suffix(28).map(\.value).min().map(Int.init) ?? 0
    }
    
    private func maxSleepHours() -> Int {
        hkManager.sleepData.suffix(28).map(\.value).max().map(Int.init) ?? 0
    }
    
    private func sleepTip() -> String {
        let avg = averageSleepHours()
        if avg >= 8 {
            return "🌟 Great sleep habits!"
        } else if avg >= 6 {
            return "😴 Try to get a bit more rest."
        } else {
            return "⚠️ Warning: Insufficient sleep!"
        }
    }
    
    private func averageSleep() -> Int {
        let total = hkManager.sleepData.map(\.value).reduce(0, +)
        return Int(total / Double(max(hkManager.sleepData.count, 1)))
    }
    
    private func minSleep() -> Int {
        hkManager.sleepData.map(\.value).min().map(Int.init) ?? 0
    }
    
    private func maxSleep() -> Int {
        hkManager.sleepData.map(\.value).max().map(Int.init) ?? 0
    }
    
    
    private func angles(for data: [DateValueChartData]) -> [(metric: DateValueChartData, start: Angle, end: Angle)] {
        let total = data.map(\.value).reduce(0, +)
        var currentAngle = Angle(degrees: 0)
        var result: [(DateValueChartData, Angle, Angle)] = []
        
        for metric in data {
            let angle = Angle(degrees: (metric.value / total) * 360)
            result.append((metric, currentAngle, currentAngle + angle))
            currentAngle += angle
        }
        return result
    }
    
    // MARK: - Additional
    private func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    private struct DonutSliceShape: Shape {
        var startAngle: Angle
        var endAngle: Angle
        
        func path(in rect: CGRect) -> Path {
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let innerRadius = radius * 0.6
            
            var path = Path()
            path.addArc(center: center, radius: radius, startAngle: startAngle - .degrees(90), endAngle: endAngle - .degrees(90), clockwise: false)
            path.addArc(center: center, radius: innerRadius, startAngle: endAngle - .degrees(90), endAngle: startAngle - .degrees(90), clockwise: true)
            path.closeSubpath()
            return path
        }
    }
}
