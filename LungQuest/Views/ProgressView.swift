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
                    
                    // Goal progress and calendar
                    GoalProgressSection()
                    
                    // Puff count chart
                    PuffCountChartSection(timeFrame: selectedTimeFrame)
                    
                    // Achievements
                    AchievementsSection()
                    
                    // Health milestones
                    HealthMilestonesSection()
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Progress")
            .breathableBackground()
        }
    }
}

struct StatsOverviewSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            // Large Days vape-free card (centered)
            VStack(spacing: 12) {
                Text("Days vape-free")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text("\(daysFromStartDate)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                
                Text("Your streak keeps lungs brighter and cravings quieter.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Grid of 4 cards
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                StatCard(
                    title: "Money Saved",
                    value: String(format: "$%.0f", moneySavedFromStartDate),
                    emoji: "💰",
                    color: .blue,
                    subtitle: "Keep it up!"
                )
                
                StatCard(
                    title: "Longest Streak",
                    value: "\(longestStreakFromStartDate)",
                    emoji: "🏆",
                    color: .orange,
                    subtitle: "Personal best"
                )
                
                StatCard(
                    title: "Total XP",
                    value: "\(appState.statistics.totalXP)",
                    emoji: "⭐",
                    color: .purple,
                    subtitle: "Level \(appState.statistics.currentLevel)"
                )
                
                StatCard(
                    title: "Quests Done",
                    value: "\(appState.statistics.completedQuests)",
                    emoji: "🎯",
                    color: .pink,
                    subtitle: "Challenges conquered"
                )
            }
            
            if let highlight = savingsHighlight {
                MotivationTile(emoji: highlight.emoji, accent: highlight.color, message: highlight.message)
            }
        }
    }
    
    private var daysFromStartDate: Int {
        guard let startDate = appState.currentUser?.startDate else { return 0 }
        let elapsed = Date().timeIntervalSince(startDate)
        return max(0, Int(elapsed) / 86_400)
    }
    
    private var moneySavedFromStartDate: Double {
        guard let user = appState.currentUser else { return 0 }
        
        // Get daily cost from onboarding, or use $20/week as fallback
        let weeklyCost = user.profile.vapingHistory.dailyCost > 0 
            ? user.profile.vapingHistory.dailyCost 
            : 20.0
        let dailyCost = weeklyCost / 7.0
        
        // Calculate days from startDate (same as main counter)
        let days = daysFromStartDate
        
        return Double(days) * dailyCost
    }
    
    private var longestStreakFromStartDate: Int {
        guard let startDate = appState.currentUser?.startDate else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var longestStreak = 0
        var currentStreak = 0
        var currentDate = startDate
        
        // Calculate longest streak from startDate
        while currentDate <= today {
            let dayStart = calendar.startOfDay(for: currentDate)
            let hasCheckIn = appState.dailyProgress.contains { progress in
                calendar.isDate(progress.date, inSameDayAs: dayStart) && progress.wasVapeFree
            }
            
            if hasCheckIn {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return longestStreak
    }
    
    private var savingsHighlight: (emoji: String, message: String, color: Color)? {
        let savings = moneySavedFromStartDate
        switch savings {
        case ..<5:
            return ("🍃", "Every dollar counts—$\(Int(savings)) saved already is a fresh start fund.", Color.green)
        case 5..<12:
            return ("☕", "You've saved enough for a cozy coffee break—treat yourself mindfully!", Color.brown)
        case 12..<25:
            return ("🍔", "That's a lunch paid for by your lungs. Savor the win!", Color.orange)
        case 25..<60:
            return ("🎬", "Tickets covered—plan a celebration night with your savings.", Color.purple)
        default:
            return ("✈️", "Your savings could fund a weekend getaway. Keep investing in freedom!", Color.blue)
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
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your progress vs. your plan")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("See how consistently you’re staying vape-free against your goal.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if progressData.isEmpty {
                EmptyChartView(message: "No data available for this period")
            } else {
                Chart {
                    ForEach(progressData, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Plan", 1.0)
                        )
                        .foregroundStyle(Color.green.opacity(0.35))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
                    }
                    
                    ForEach(progressData, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Progress", item.cumulativeSuccessRatio)
                        )
                        .foregroundStyle(Color(red: 0.85, green: 0.32, blue: 0.57))
                        .lineStyle(StrokeStyle(lineWidth: 3))
                    }
                }
                .frame(height: 210)
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
                
                Text(progressSummary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 6)
            }
        }
        .softCard(accent: Color(red: 0.31, green: 0.57, blue: 0.99), cornerRadius: 28)
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
    
    private var progressSummary: String {
        guard let latest = progressData.last?.cumulativeSuccessRatio else {
            return "Log a few more days to see how your streak stacks up."
        }
        let percent = Int(latest * 100)
        switch percent {
        case ..<40:
            return "You’re laying the groundwork—each day logged raises your progress curve."
        case 40..<70:
            return "Your streak is above halfway. Keep noting wins to reach full momentum!"
        case 70..<95:
            return "You’re ahead of plan—consistency is clearly paying off."
        default:
            return "You’re staying amazingly consistent. Celebrate how steady your journey feels!"
        }
    }
}

struct CravingsChartSection: View {
    @EnvironmentObject var appState: AppState
    let timeFrame: ProgressView.TimeFrame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Cravings level")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Track how urges change so you can plan calming rituals.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if chartData.isEmpty {
                EmptyChartView(message: "No craving data available")
            } else {
                Chart {
                    ForEach(chartData, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Cravings", item.cravingsLevel)
                        )
                        .foregroundStyle(Color.orange)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Cravings", item.cravingsLevel)
                        )
                        .foregroundStyle(Color.orange.opacity(0.2))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 180)
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
        .softCard(accent: Color.orange, cornerRadius: 28)
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
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Recent achievements")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Badges reflect your consistency and courage—collect your latest wins.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if appState.statistics.badges.isEmpty {
                Text("Complete quests and maintain streaks to unlock badges!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    ForEach(Array(appState.statistics.badges.suffix(6))) { badge in
                        BadgeView(badge: badge)
                    }
                }
            }
        }
        .softCard(accent: .purple, cornerRadius: 28)
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
    
    private var daysFromStartDate: Int {
        guard let startDate = appState.currentUser?.startDate else { return 0 }
        let elapsed = Date().timeIntervalSince(startDate)
        return max(0, Int(elapsed) / 86_400)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Health milestones")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Every day vape-free unlocks new healing moments for your body.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 14) {
                ForEach(milestones, id: \.days) { milestone in
                    MilestoneRow(
                        title: milestone.title,
                        description: milestone.description,
                        isCompleted: daysFromStartDate >= milestone.days,
                        daysRequired: milestone.days,
                        currentDays: daysFromStartDate
                    )
                }
            }
        }
        .softCard(accent: .green, cornerRadius: 28)
    }
}

struct MilestoneRow: View {
    let title: String
    let description: String
    let isCompleted: Bool
    let daysRequired: Int
    let currentDays: Int
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill((isCompleted ? Color.green : Color.orange).opacity(0.18))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke((isCompleted ? Color.green : Color.orange).opacity(0.3), lineWidth: 1)
                    )
                Image(systemName: isCompleted ? "checkmark" : "clock")
                    .foregroundColor(isCompleted ? .green : .orange)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundColor(isCompleted ? .green : .primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                if !isCompleted {
                    Text("\(max(0, daysRequired - currentDays)) days to go")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(isCompleted ? 0.85 : 0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
        )
        .opacity(isCompleted ? 1.0 : 0.85)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let emoji: String
    let color: Color
    let subtitle: String?
    
    init(title: String, value: String, emoji: String, color: Color, subtitle: String? = nil) {
        self.title = title
        self.value = value
        self.emoji = emoji
        self.color = color
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Emoji at top
            Text(emoji)
                .font(.system(size: 36))
            
            // Value
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .monospacedDigit()
            
            // Title
            Text(title.uppercased())
                .font(.caption2)
                .kerning(0.8)
                .foregroundColor(.secondary)
            
            // Subtitle if available
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(color.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
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

struct PuffCountChartSection: View {
    @EnvironmentObject var appState: AppState
    let timeFrame: ProgressView.TimeFrame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily puff count")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Notice how your puffs shrink as your streak grows.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "lungs.fill")
                    .foregroundColor(.orange)
            }
            
            if filteredProgressData.isEmpty {
                EmptyChartView(message: "No puff data available for this time period")
            } else {
                Chart(filteredProgressData, id: \.date) { progress in
                    LineMark(
                        x: .value("Date", progress.date),
                        y: .value("Puffs", progress.puffInterval.numericValue)
                    )
                    .foregroundStyle(progress.puffInterval.color)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Date", progress.date),
                        y: .value("Puffs", progress.puffInterval.numericValue)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [progress.puffInterval.color.opacity(0.3), progress.puffInterval.color.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    PointMark(
                        x: .value("Date", progress.date),
                        y: .value("Puffs", progress.puffInterval.numericValue)
                    )
                    .foregroundStyle(progress.puffInterval.color)
                    .symbolSize(50)
                }
                .frame(height: 210)
                .chartYScale(domain: 0...4)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: timeFrame == .week ? 1 : 7)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        if let intValue = value.as(Int.self),
                           let interval = PuffInterval.allCases.first(where: { $0.numericValue == intValue }) {
                            AxisValueLabel(interval.shortName)
                        }
                    }
                }
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Most common")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(mostCommonInterval.displayName)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(mostCommonInterval.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Best day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(bestInterval.displayName)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Vape-free days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(vapeFreeDays)")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
        }
        .softCard(accent: Color.orange, cornerRadius: 28)
    }
    
    private var filteredProgressData: [DailyProgress] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch timeFrame {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .all:
            startDate = appState.dailyProgress.first?.date ?? now
        }
        
        return appState.dailyProgress
            .filter { $0.date >= startDate }
            .sorted { $0.date < $1.date }
    }
    
    private var mostCommonInterval: PuffInterval {
        guard !filteredProgressData.isEmpty else { return .none }
        let intervalCounts = Dictionary(grouping: filteredProgressData, by: { $0.puffInterval })
        return intervalCounts.max(by: { $0.value.count < $1.value.count })?.key ?? .none
    }
    
    private var bestInterval: PuffInterval {
        filteredProgressData.map { $0.puffInterval }.min(by: { $0.numericValue < $1.numericValue }) ?? .none
    }
    
    private var vapeFreeDays: Int {
        filteredProgressData.filter { $0.puffInterval == .none }.count
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

struct MotivationTile: View {
    let emoji: String
    var accent: Color = .pink
    let message: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.system(size: 24))
                .padding(10)
                .background(
                    Circle().fill(accent.opacity(0.15))
                )
            Text(message).font(.caption).foregroundColor(.secondary)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(accent.opacity(0.12))
        )
    }
}

struct GoalProgressSection: View {
    @EnvironmentObject var appState: AppState
    @State private var currentDate = Date()
    @State private var selectedMonth = Date()
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            // Goal Progress Card
            VStack(alignment: .leading, spacing: 16) {
                // Today's date
                Text("Today is \(formattedDate)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Progress to Goal
                HStack(spacing: 12) {
                    // Target icon
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "target")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Progress to Goal: \(progressPercentage)% complete")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.green)
                                    .frame(width: geometry.size.width * CGFloat(progressPercentage) / 100, height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                        Text("\(currentDays)/\(targetDays) Days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Next Milestone
                HStack(spacing: 12) {
                    // Mountain icon
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "mountain.2.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next Milestone: Final Goal!")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Text(countdownTimer)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
            )
            
            // Calendar Card
            VStack(spacing: 16) {
                // Calendar header
                HStack {
                    Button(action: { changeMonth(-1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: { changeMonth(1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 4)
                
                // Days of week
                HStack(spacing: 0) {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                    ForEach(calendarDays, id: \.id) { day in
                        CalendarDayView(
                            day: day,
                            isToday: isToday(day.date),
                            isStartDate: isStartDate(day.date),
                            isGoalDate: isGoalDate(day.date),
                            isInProgressRange: isInProgressRange(day.date)
                        )
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
            )
        }
        .softCard(accent: Color.gray, cornerRadius: 28)
        .onAppear {
            currentDate = Date()
            selectedMonth = Date()
            // Start timer to update countdown every second
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                currentDate = Date()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d'\(daySuffix)' MMMM"
        return formatter.string(from: currentDate)
    }
    
    private var daySuffix: String {
        let day = Calendar.current.component(.day, from: currentDate)
        switch day {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
    private var currentDays: Int {
        appState.daysSinceQuitStartDate()
    }
    
    private var targetDays: Int {
        appState.currentUser?.quitGoal.targetDays ?? 30
    }
    
    private var progressPercentage: Int {
        guard targetDays > 0 else { return 0 }
        return min(100, Int((Double(currentDays) / Double(targetDays)) * 100))
    }
    
    private var countdownTimer: String {
        let daysRemaining = max(0, targetDays - currentDays)
        guard let startDate = appState.currentUser?.startDate,
              let goalDate = Calendar.current.date(byAdding: .day, value: targetDays, to: startDate) else {
            return "\(daysRemaining)d 23h 59m 08s"
        }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: now, to: goalDate)
        let hours = max(0, components.hour ?? 0)
        let minutes = max(0, components.minute ?? 0)
        let seconds = max(0, components.second ?? 0)
        
        return "\(daysRemaining)d \(hours)h \(minutes)m \(seconds)s"
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private func changeMonth(_ direction: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: direction, to: selectedMonth) {
            selectedMonth = newMonth
        }
    }
    
    private var calendarDays: [CalendarDay] {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        guard let daysInMonth = calendar.range(of: .day, in: .month, for: selectedMonth) else {
            return []
        }
        
        var days: [CalendarDay] = []
        
        // Previous month's days
        if firstWeekday > 0 {
            if let prevMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth),
               let prevMonthRange = calendar.range(of: .day, in: .month, for: prevMonth) {
                let lastDayOfPrevMonth = prevMonthRange.upperBound - 1
                let startDay = lastDayOfPrevMonth - firstWeekday + 1
                
                for i in startDay...lastDayOfPrevMonth {
                    if let date = calendar.date(byAdding: .day, value: i - lastDayOfPrevMonth, to: startOfMonth) {
                        days.append(CalendarDay(date: date, dayNumber: i, isCurrentMonth: false))
                    }
                }
            }
        }
        
        // Current month's days
        for day in daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(CalendarDay(date: date, dayNumber: day, isCurrentMonth: true))
            }
        }
        
        // Next month's days to fill the grid (6 weeks = 42 days)
        let remainingDays = 42 - days.count
        if remainingDays > 0 {
            for day in 1...remainingDays {
                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth),
                   let date = calendar.date(byAdding: .day, value: day - 1, to: nextMonth) {
                    days.append(CalendarDay(date: date, dayNumber: day, isCurrentMonth: false))
                }
            }
        }
        
        return days
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private func isStartDate(_ date: Date) -> Bool {
        guard let startDate = appState.currentUser?.startDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: startDate)
    }
    
    private func isGoalDate(_ date: Date) -> Bool {
        guard let startDate = appState.currentUser?.startDate,
              let goalDate = Calendar.current.date(byAdding: .day, value: targetDays, to: startDate) else {
            return false
        }
        return Calendar.current.isDate(date, inSameDayAs: goalDate)
    }
    
    private func isInProgressRange(_ date: Date) -> Bool {
        guard let startDate = appState.currentUser?.startDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let checkDate = calendar.startOfDay(for: date)
        let start = calendar.startOfDay(for: startDate)
        
        return checkDate >= start && checkDate < today && !isStartDate(date)
    }
}

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let dayNumber: Int
    let isCurrentMonth: Bool
}

struct CalendarDayView: View {
    let day: CalendarDay
    let isToday: Bool
    let isStartDate: Bool
    let isGoalDate: Bool
    let isInProgressRange: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(day.dayNumber)")
                .font(.system(size: 14, weight: isToday ? .bold : .regular))
                .foregroundColor(dayColor)
                .frame(width: 32, height: 32)
                .background(backgroundShape)
            
            if isStartDate {
                Image(systemName: "circle.fill")
                    .font(.system(size: 4))
                    .foregroundColor(.red)
                    .offset(y: -2)
            } else if isGoalDate {
                ZStack {
                    Circle()
                        .stroke(Color.green, lineWidth: 1.5)
                        .frame(width: 16, height: 16)
                    Image(systemName: "target")
                        .font(.system(size: 7))
                        .foregroundColor(.green)
                }
                .offset(y: -2)
            } else {
                Spacer()
                    .frame(height: 4)
            }
        }
        .frame(height: 44)
    }
    
    private var dayColor: Color {
        if !day.isCurrentMonth {
            return .gray.opacity(0.3)
        } else if isToday {
            return .primary
        } else if isStartDate {
            return .green
        } else if isInProgressRange {
            return .green
        } else {
            return .primary
        }
    }
    
    @ViewBuilder
    private var backgroundShape: some View {
        if isToday {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
        } else if isStartDate && day.isCurrentMonth {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(0.15))
        } else if isInProgressRange && day.isCurrentMonth {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(0.1))
        } else {
            Color.clear
        }
    }
}

#Preview {
    ProgressView()
        .environmentObject(AppState())
}
