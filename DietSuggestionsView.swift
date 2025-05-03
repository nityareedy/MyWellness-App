//
//  DietSuggestionsView.swift
//  Step Tracker
//
//  Created by Nitya Reddy on 5/3/25.
//
import SwiftUI
import HealthKit

struct DietSuggestionView: View {
    @State private var height: Double = 170  // in cm
    @State private var weight: Double = 65   // in kg
    @State private var age: Int = 25
    @State private var isMale: Bool = true
    @State private var activityLevel: Double = 1.375
    @State private var goal: String = "Maintain"
    @State private var isVeg: Bool = true
    @State private var showMealSuggestions = false
    @State private var showExercises = false
    @State private var targetDelta: Double = 2.0 // kg to gain or lose
    @State private var weeksToTarget: Int = 4

    private let healthStore = HKHealthStore()


    var body: some View {
        let bmr = calculateBMR()
        let calories = dailyCalories(bmr: bmr)
        let adjustment = abs(calories - (bmr * activityLevel)) // positive number

        Form {
            Section(header: Text("User Info")) {
                TextField("Height (cm)", value: $height, format: .number)
                TextField("Weight (kg)", value: $weight, format: .number)
                TextField("Age", value: $age, format: .number)
                Picker("Gender", selection: $isMale) {
                    Text("Male").tag(true)
                    Text("Female").tag(false)
                }.pickerStyle(.segmented)
            }
            
            Section(header: Text("Health Insight")) {
                Text("Your BMI is \(String(format: "%.1f", currentBMI))")
                
                Text("Healthy weight range for your height: \(String(format: "%.1f", healthyWeightRange.min)) – \(String(format: "%.1f", healthyWeightRange.max)) kg")
                
                if let suggestion = recommendedAdjustment {
                    Text("You may consider aiming to **\(suggestion.direction)** approximately **\(String(format: "%.1f", suggestion.amount)) kg**")
                        .fontWeight(.semibold)
                        .foregroundColor(suggestion.direction == "gain" ? .blue : .red)
                } else {
                    Text("🎉 You are within a healthy weight range!")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            Section(header: Text("Activity & Goal")) {
                Picker("Activity Level", selection: $activityLevel) {
                    Text("Sedentary").tag(1.2)
                    Text("Lightly Active").tag(1.375)
                    Text("Moderately Active").tag(1.55)
                    Text("Very Active").tag(1.725)
                    Text("Super Active").tag(1.9)
                }

                Picker("Goal", selection: $goal) {
                    Text("Lose").tag("Lose")
                    Text("Maintain").tag("Maintain")
                    Text("Gain").tag("Gain")
                }
                if goal != "Maintain" {
                    Section(header: Text("Goal Details")) {
                        TextField("How many kg to \(goal.lowercased())?", value: $targetDelta, format: .number)
                            .keyboardType(.default)

                        Picker("In how many weeks?", selection: $weeksToTarget) {
                            ForEach(1...12, id: \.self) { week in
                                Text("\(week) week\(week > 1 ? "s" : "")").tag(week)
                            }
                        }
                    }
                }

                Toggle("Vegetarian", isOn: $isVeg)
            }

            Section(header: Text("Results")) {
                let bmr = calculateBMR()
                let calories = dailyCalories(bmr: bmr)
                let macros = macroBreakdown(calories: calories)

                Text("Calories: \(Int(calories)) kcal/day")
                Text("Carbs: \(macros.carbs)g, Protein: \(macros.protein)g, Fat: \(macros.fat)g")
            }
            Section {
                            Button("View Suggested Meals") {
                                showMealSuggestions = true
                            }
                            .foregroundColor(.blue)
                            .font(.headline)
                        }
            Section {
                Button("View Exercise Suggestions") {
                    showExercises = true
                }
                .foregroundColor(.blue)
            }
            .sheet(isPresented: $showExercises) {
                ExerciseSuggestionsView(weight: weight, dailyAdjustment: calculatedDailyAdjustment)
            }

        }
        .gesture(
            DragGesture().onChanged { _ in
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
        .navigationTitle("Diet Plan")
        .task {
            await loadHealthData()
        }
        .sheet(isPresented: $showMealSuggestions) {
            MealSuggestionsView(isVeg: isVeg, calories: calculatedCalories)
        }

        

    }
       
    
    // MARK: - HealthKit Integration

   
    func loadHealthData() async {
        do {
            // Height
            if let heightType = HKQuantityType.quantityType(forIdentifier: .height) {
                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
                let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, _ in
                    if let sample = results?.first as? HKQuantitySample {
                        let meters = sample.quantity.doubleValue(for: .meter())
                        DispatchQueue.main.async {
                            self.height = meters * 100 // Convert to cm
                        }
                    }
                }
                healthStore.execute(query)
            }

            // Weight
            if let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) {
                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
                let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, _ in
                    if let sample = results?.first as? HKQuantitySample {
                        let kg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                        DispatchQueue.main.async {
                            self.weight = kg
                        }
                    }
                }
                healthStore.execute(query)
            }

            // Age & Sex
            let birthComponents = try healthStore.dateOfBirthComponents()
            let biologicalSex = try healthStore.biologicalSex()

            if let dob = Calendar.current.date(from: birthComponents) {
                let ageComponents = Calendar.current.dateComponents([.year], from: dob, to: Date())
                DispatchQueue.main.async {
                    self.age = ageComponents.year ?? 25
                }
            }

            DispatchQueue.main.async {
                self.isMale = biologicalSex.biologicalSex == .male
            }

        } catch {
            print("⚠️ Error loading HealthKit data: \(error.localizedDescription)")
        }
    }

    // MARK: - Calculations

    private func calculateBMR() -> Double {
        if isMale {
            return 10 * weight + 6.25 * height - 5 * Double(age) + 5
        } else {
            return 10 * weight + 6.25 * height - 5 * Double(age) - 161
        }
    }

    private func dailyCalories(bmr: Double) -> Double {
        var result = bmr * activityLevel

        guard goal != "Maintain", targetDelta > 0, weeksToTarget > 0 else {
            return result
        }

        let totalKcalNeeded = targetDelta * 7700
        let days = Double(weeksToTarget * 7)
        let dailyAdjustment = totalKcalNeeded / days

        if goal == "Lose" {
            result -= dailyAdjustment
        } else if goal == "Gain" {
            result += dailyAdjustment
        }

        return result
    }


    private func macroBreakdown(calories: Double) -> (carbs: Int, protein: Int, fat: Int) {
        let carbs = Int((calories * 0.4) / 4)
        let protein = Int((calories * 0.3) / 4)
        let fat = Int((calories * 0.3) / 9)
        return (carbs, protein, fat)
    }
    
    private var calculatedBMR: Double {
           calculateBMR()
       }

       private var calculatedCalories: Double {
           dailyCalories(bmr: calculatedBMR)
       }

       private var calculatedDailyAdjustment: Double {
           abs(calculatedCalories - (calculatedBMR * activityLevel))
       }
       
    
    private var currentBMI: Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }

    private var healthyWeightRange: (min: Double, max: Double) {
        let heightInMeters = height / 100
        let min = 18.5 * heightInMeters * heightInMeters
        let max = 24.9 * heightInMeters * heightInMeters
        return (min, max)
    }

    private var recommendedAdjustment: (direction: String, amount: Double)? {
        if weight < healthyWeightRange.min {
            return ("gain", healthyWeightRange.min - weight)
        } else if weight > healthyWeightRange.max {
            return ("lose", weight - healthyWeightRange.max)
        } else {
            return nil
        }
    }

}

    


