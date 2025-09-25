import SwiftUI
import Charts

struct ProgressView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTimeFrame: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case all = "All Time"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header stats
                    StatsOverviewSection()
                    
                    // Time frame selector
                    TimeFrameSelector(selectedTimeFrame: $selectedTimeFrame)
                    
                    // Progress vs Plan chart
                    ProgressVsPlanSection(timeFrame: selectedTimeFrame)
                    
                    // Cravings chart
                    CravingsChartSection(timeFrame: selectedTimeFrame)
                    
                    // Achievements
                    AchievementsSection()
                    
                    // Health milestones
                    HealthMilestonesSection()
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Progress")
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.green.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct StatsOverviewSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            // Main stat - days vape free
            VStack(spacing: 8) {
                Text("\(appState.getDaysVapeFree())")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                Text("Days Vape-Free")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.green.opacity(0.1))
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
            
            // Secondary stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                StatCard(
                    title: "Money Saved",
                    value: String(format: "$%.0f", appState.getMoneySaved()),
                    icon: "dollarsign.circle.fill",
                    color: .blue,
                    subtitle: "Keep it up!"
                )
                
                StatCard(
                    title: "Longest Streak",
                    value: "\(appState.currentUser?.quitGoal.longestStreak ?? 0)",
                    icon: "flame.fill",
                    color: .orange,
                    subtitle: "Personal best"
                )
                
                StatCard(
                    title: "Total XP",
                    value: "\(appState.statistics.totalXP)",
                    icon: "star.fill",
                    color: .purple,
                    subtitle: "Level \(appState.statistics.currentLevel)"
                )
                
                StatCard(
                    title: "Quests Done",
                    value: "\(appState.statistics.completedQuests)",
                    icon: "target",
                    color: .pink,
                    subtitle: "Challenges conquered"
                )
            }
        }
    }
}

struct TimeFrameSelector: View {
    @Binding var selectedTimeFrame: ProgressView.TimeFrame
    
    var body: some View {
        HStack {
            Text("View")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Picker("Time Frame", selection: $selectedTimeFrame) {
                ForEach(ProgressView.TimeFrame.allCases, id: \.self) { timeFrame in
                    Text(timeFrame.rawValue).tag(timeFrame)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: 200)
        }
    }
}

struct ProgressVsPlanSection: View {
    @EnvironmentObject var appState: AppState
    let timeFrame: ProgressView.TimeFrame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Progress vs. Your Plan")
                .font(.headline)
                .fontWeight(.semibold)
            
            if progressData.isEmpty {
                EmptyChartView(message: "No data available for this period")
            } else {
                Chart {
                    // Plan line (target = 100% vape-free)
                    ForEach(progressData, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Plan", 1.0)
                        )
                        .foregroundStyle(.green.opacity(0.4))
                    }
                    
                    // Actual cumulative progress (ratio of vape-free days)
                    ForEach(progressData, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Progress", item.cumulativeSuccessRatio)
                        )
                        .foregroundStyle(.pink)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...1)
                .chartYAxis {
                    AxisMarks(values: [0, 0.25, 0.5, 0.75, 1.0]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let d = value.as(Double.self) {
                                Text("\(Int(d * 100))%")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(radius: 5)
        )
    }
    
    private struct ProgressPoint { let date: Date; let cumulativeSuccessRatio: Double }
    
    private var progressData: [ProgressPoint] {
        let calendar = Calendar.current
        let now = Date()
        
        let days: Int
        switch timeFrame {
        case .week: days = 7
        case .month: days = 30
        case .all: days = Int(now.timeIntervalSince(appState.currentUser?.startDate ?? now) / 86400) + 1
        }
        
        let startDate = calendar.date(byAdding: .day, value: -days + 1, to: now) ?? now
        let slice = appState.dailyProgress
            .filter { $0.date >= startDate }
            .sorted { $0.date < $1.date }
        
        var cumulative: [ProgressPoint] = []
        var total = 0
        var successes = 0
        var lastDay: Date? = nil
        
        for p in slice {
            total += 1
            if p.wasVapeFree { successes += 1 }
            let ratio = total > 0 ? Double(successes) / Double(total) : 0
            let day = calendar.startOfDay(for: p.date)
            if let prev = lastDay, prev == day {
                cumulative.removeLast()
            }
            cumulative.append(ProgressPoint(date: day, cumulativeSuccessRatio: ratio))
            lastDay = day
        }
        return cumulative
    }
}

struct CravingsChartSection: View {
    @EnvironmentObject var appState: AppState
    let timeFrame: ProgressView.TimeFrame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Cravings Level")
                .font(.headline)
                .fontWeight(.semibold)
            
            if chartData.isEmpty {
                EmptyChartView(message: "No craving data available")
            } else {
                Chart {
                    ForEach(chartData, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Cravings", item.cravingsLevel)
                        )
                        .foregroundStyle(.orange)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Cravings", item.cravingsLevel)
                        )
                        .foregroundStyle(.orange.opacity(0.2))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 150)
                .chartYScale(domain: 1...5)
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    }
                }
            }
            
            // Legend
            HStack {
                Text("Lower is better")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 15) {
                    LegendItem(color: .green, text: "1-2: Minimal")
                    LegendItem(color: .yellow, text: "3: Moderate")
                    LegendItem(color: .red, text: "4-5: Intense")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(radius: 5)
        )
    }
    
    private var chartData: [DailyProgress] {
        let calendar = Calendar.current
        let now = Date()
        
        let days: Int
        switch timeFrame {
        case .week: days = 7
        case .month: days = 30
        case .all: days = Int(now.timeIntervalSince(appState.currentUser?.startDate ?? now) / 86400) + 1
        }
        
        let startDate = calendar.date(byAdding: .day, value: -days + 1, to: now) ?? now
        
        return appState.dailyProgress
            .filter { $0.date >= startDate && $0.cravingsLevel > 0 }
            .sorted { $0.date < $1.date }
    }
}

struct AchievementsSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Achievements")
                .font(.headline)
                .fontWeight(.semibold)
            
            if appState.statistics.badges.isEmpty {
                Text("Complete quests and maintain streaks to unlock badges!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                    ForEach(Array(appState.statistics.badges.suffix(6))) { badge in
                        BadgeView(badge: badge)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(radius: 5)
        )
    }
}

struct HealthMilestonesSection: View {
    @EnvironmentObject var appState: AppState
    
    private let milestones = [
        (days: 1, title: "20 minutes", description: "Heart rate and blood pressure drop"),
        (days: 3, title: "72 hours", description: "Nicotine is completely out of your system"),
        (days: 7, title: "1 week", description: "Taste and smell improve"),
        (days: 30, title: "1 month", description: "Lung function increases up to 30%"),
        (days: 90, title: "3 months", description: "Circulation improves significantly"),
        (days: 365, title: "1 year", description: "Risk of heart disease cut in half")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Health Milestones")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                ForEach(milestones, id: \.days) { milestone in
                    MilestoneRow(
                        title: milestone.title,
                        description: milestone.description,
                        isCompleted: appState.getDaysVapeFree() >= milestone.days,
                        daysRequired: milestone.days,
                        currentDays: appState.getDaysVapeFree()
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(radius: 5)
        )
    }
}

struct MilestoneRow: View {
    let title: String
    let description: String
    let isCompleted: Bool
    let daysRequired: Int
    let currentDays: Int
    
    var body: some View {
        HStack(spacing: 15) {
            // Status icon
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: isCompleted ? "checkmark" : "clock")
                    .foregroundColor(isCompleted ? .green : .gray)
                    .font(.title3)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isCompleted ? .green : .primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if !isCompleted {
                    Text("\(daysRequired - currentDays) days to go")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .opacity(isCompleted ? 1.0 : 0.7)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String?
    
    init(title: String, value: String, icon: String, color: Color, subtitle: String? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(color)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(radius: 5)
        )
    }
}

struct BadgeView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: badge.icon)
                .font(.title2)
                .foregroundColor(.yellow)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color.yellow.opacity(0.1))
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}

struct EmptyChartView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.bar")
                .font(.title)
                .foregroundColor(.gray)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(text)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProgressView()
        .environmentObject(AppState())
}
