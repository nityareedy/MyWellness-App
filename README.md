# 🩺 My Wellness App – Personalized Health & Fitness App

**My Wellness App** is an iOS app built using **SwiftUI** and **HealthKit**. It helps users track their health, set personalized goals, and get diet and exercise suggestions tailored to their body and lifestyle.

---

## 📱 Features

### 🧑‍⚕️ Health Metrics Dashboard
-  **Height Tracking**
-  **Weight History & Trends**
-  **Heart Rate Monitoring**
-  **Sleep Duration Tracking**
-  Beautiful, interactive charts for all metrics
-  All data fetched automatically from **Apple Health**

---

### 🔥 Personalized Calorie & Macro Targets
- Calculates **daily calorie needs** based on:
  - BMR (Basal Metabolic Rate)
  - Activity level
  - Weight goal (gain/lose/maintain)
  - How much weight the user wants to change and in how many weeks
- Shows **macronutrient targets** (carbs, protein, fat)

---

### 🥗 Smart Diet Recommendations
-  **Veg & Non-Veg options**
- Portion size **scales with calorie goal**
- Covers **breakfast, lunch, dinner, snacks**
- Dynamically updates with weight goal

---

### 🏃 Exercise Suggestions with Burn Estimates
- Based on your **current weight** and **goal deficit**
- Shows how many calories you’ll burn:
  - For 15 and 30 minutes
  - Or how many reps (e.g., jump rope) to burn 100 kcal
- Includes: Running, Cycling, Jump Rope, Yoga, etc.

---

### 🧠 Health Insight Section
- Displays your **BMI**
- Shows **healthy weight range** for your height
- Tells you if you should consider gaining or losing weight
- Suggests how many kg to change to reach optimal BMI

---

### 🔐 Private by Design
- No third-party APIs
- All calculations done on-device
- Reads only from HealthKit with your permission

---

## 🧰 Tech Stack

- **SwiftUI** – Modern iOS UI framework
- **HealthKit** – Apple health data access
- **MVVM** – Simple and clean architecture

---

## 🚀 Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/yourusername/MyWellness-App.git
   cd MyWellness-App
   ```
2. Open in Xcode
   
3. Build & Run
- Use a physical iOS device (HealthKit won’t work in the simulator)
- Enable Developer Mode on your iPhone
- Accept HealthKit permission prompts on first launch


