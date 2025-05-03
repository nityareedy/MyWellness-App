//
//  MealSuggestionsView.swift
//  Step Tracker
//
//  Created by Nitya Reddy on 5/3/25.
//

import SwiftUI

struct MealSuggestionsView: View {
    let isVeg: Bool
    let calories: Double

    var body: some View {
        NavigationView {
            List {
                Text("Daily calorie target: \(Int(calories)) kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                let plan = mealPlan(calories: calories)

                ForEach(["breakfast", "lunch", "dinner", "snack"], id: \.self) { type in
                    Section(header: Text(mealHeader(for: type))) {
                        ForEach(plan[type] ?? [], id: \.self) { meal in
                            Text("• \(meal)")
                        }
                    }
                }
            }
            .navigationTitle(isVeg ? "Veg Meals" : "Non-Veg Meals")
        }
    }

    // MARK: - Helper

    func mealHeader(for type: String) -> String {
        switch type {
        case "breakfast": return "🍳 Breakfast"
        case "lunch": return "🥗 Lunch"
        case "dinner": return "🍛 Dinner"
        case "snack": return "🍎 Snacks"
        default: return type.capitalized
        }
    }

    func mealPlan(calories: Double) -> [String: [String]] {
        if calories < 1600 {
            return isVeg ? vegMealsLow : nonVegMealsLow
        } else if calories <= 2200 {
            return isVeg ? vegMealsMid : nonVegMealsMid
        } else {
            return isVeg ? vegMealsHigh : nonVegMealsHigh
        }
    }

    // MARK: - Meals Data

    let vegMealsLow = [
        "breakfast": [
            "½ cup oats + 1 small banana",
            "1 besan chilla + mint chutney"
        ],
        "lunch": [
            "1 roti + ½ cup dal",
            "½ cup rice + stir-fried vegetables"
        ],
        "dinner": [
            "1 bowl vegetable soup + 1 toast",
            "1 roti + ½ cup sabzi"
        ],
        "snack": [
            "Fruit + 4 almonds",
            "½ cup buttermilk"
        ]
    ]

    let vegMealsMid = [
        "breakfast": [
            "1 cup oats + banana + nuts",
            "2 besan chilla + chutney"
        ],
        "lunch": [
            "2 rotis + 1 cup dal + salad",
            "1 cup rice + 1 cup paneer curry"
        ],
        "dinner": [
            "1.5 cups soup + 2 toast + salad",
            "2 rotis + 1 cup sabzi + curd"
        ],
        "snack": [
            "Fruit + 6 almonds + ½ protein bar",
            "1 glass buttermilk + peanuts"
        ]
    ]

    let vegMealsHigh = [
        "breakfast": [
            "1.5 cup oats + banana + nuts + honey",
            "3 chilla + peanut butter + smoothie"
        ],
        "lunch": [
            "3 rotis + 1.5 cup dal + 1 cup rice",
            "1.5 cup paneer curry + curd + salad"
        ],
        "dinner": [
            "2 cups soup + 2 rotis + sabzi + dessert",
            "2 cups rice + tofu curry + ghee"
        ],
        "snack": [
            "Banana shake + nuts + granola bar",
            "Protein smoothie + 2 dates"
        ]
    ]

    let nonVegMealsLow = [
        "breakfast": [
            "1 boiled egg + toast",
            "½ omelette + spinach"
        ],
        "lunch": [
            "1 roti + ½ cup egg curry",
            "½ cup rice + stir-fried chicken"
        ],
        "dinner": [
            "1 bowl chicken soup + 1 toast",
            "1 egg bhurji + roti"
        ],
        "snack": [
            "Boiled egg",
            "4 almonds + ½ banana"
        ]
    ]

    let nonVegMealsMid = [
        "breakfast": [
            "2 boiled eggs + toast",
            "Omelette + smoothie"
        ],
        "lunch": [
            "2 rotis + 1 cup egg curry + salad",
            "1 cup rice + 1 cup chicken curry"
        ],
        "dinner": [
            "1.5 cups soup + 2 toast + salad",
            "2 rotis + 1 cup chicken bhurji + curd"
        ],
        "snack": [
            "Boiled egg + fruit",
            "Yogurt + almonds"
        ]
    ]

    let nonVegMealsHigh = [
        "breakfast": [
            "3 eggs + toast + peanut butter",
            "Omelette + smoothie + banana"
        ],
        "lunch": [
            "3 rotis + 1.5 cup chicken curry + rice",
            "2 cups biryani + curd"
        ],
        "dinner": [
            "Grilled chicken + salad + 2 rotis",
            "Egg curry + rice + dessert"
        ],
        "snack": [
            "Protein shake + nuts + granola",
            "Smoothie + 2 dates + banana"
        ]
    ]
}


