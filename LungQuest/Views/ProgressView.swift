import SwiftUI
import Charts

struct ProgressView: View {
    @EnvironmentObject var dataStore: AppDataStore
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
    @EnvironmentObject var dataStore: AppDataStore
    
    var body: some View {
        VStack(spacing: 24) {
            // Large Days vape-free card (primary, centered, simpler)
            VStack(spacing: 8) {
                Text("Days vape-free")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text("\(daysFromStartDate)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                
                Text("Your streak keeps lungs brighter and cravings quieter.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
            
            // Grid of 4 stat cards (secondary, unified design)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                StatCard(
                    title: "Money Saved",
                    value: String(format: "$%.0f", moneySavedFromStartDate),
                    emoji: "💰",
                    accentColor: Color(red: 0.2, green: 0.6, blue: 0.9), // Soft blue
                    subtitle: "Keep it up!"
                )
                
                StatCard(
                    title: "Longest Streak",
                    value: "\(longestStreakFromStartDate)",
                    emoji: "🏆",
                    accentColor: Color(red: 0.95, green: 0.7, blue: 0.3), // Soft orange
                    subtitle: "Personal best"
                )
                
                StatCard(
                    title: "Total XP",
                    value: "\(dataStore.statistics.totalXP)",
                    emoji: "⭐",
                    accentColor: Color(red: 0.7, green: 0.5, blue: 0.9), // Soft purple
                    subtitle: "Level \(dataStore.statistics.currentLevel)"
                )
                
                StatCard(
                    title: "Quests Done",
                    value: "\(dataStore.statistics.completedQuests)",
                    emoji: "🎯",
                    accentColor: Color(red: 0.9, green: 0.5, blue: 0.6), // Soft pink
                    subtitle: "Challenges conquered"
                )
            }
            
            if let highlight = savingsHighlight {
                MotivationTile(emoji: highlight.emoji, accent: highlight.color, message: highlight.message)
            }
        }
    }
    
    private var daysFromStartDate: Int {
        guard let startDate = dataStore.currentUser?.startDate else { return 0 }
        let elapsed = Date().timeIntervalSince(startDate)
        return max(0, Int(elapsed) / 86_400)
    }
    
    private var moneySavedFromStartDate: Double {
        guard let user = dataStore.currentUser else { return 0 }
        
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
        guard let startDate = dataStore.currentUser?.startDate else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var longestStreak = 0
        var currentStreak = 0
        var currentDate = startDate
        
        // Calculate longest streak from startDate
        while currentDate <= today {
            let dayStart = calendar.startOfDay(for: currentDate)
            let hasCheckIn = dataStore.dailyProgress.contains { progress in
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
    @EnvironmentObject var dataStore: AppDataStore
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
        .softCard(accent: Color(red: 0.45, green: 0.72, blue: 0.99), cornerRadius: 28)
    }
    
    private struct ProgressPoint { let date: Date; let cumulativeSuccessRatio: Double }
    
    private var progressData: [ProgressPoint] {
        let calendar = Calendar.current
        let now = Date()
        
        let days: Int
        switch timeFrame {
        case .week: days = 7
        case .month: days = 30
        case .all: days = Int(now.timeIntervalSince(dataStore.currentUser?.startDate ?? now) / 86400) + 1
        }
        
        let startDate = calendar.date(byAdding: .day, value: -days + 1, to: now) ?? now
        let slice = dataStore.dailyProgress
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
    @EnvironmentObject var dataStore: AppDataStore
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
        case .all: days = Int(now.timeIntervalSince(dataStore.currentUser?.startDate ?? now) / 86400) + 1
        }
        
        let startDate = calendar.date(byAdding: .day, value: -days + 1, to: now) ?? now
        
        return dataStore.dailyProgress
            .filter { $0.date >= startDate && $0.cravingsLevel > 0 }
            .sorted { $0.date < $1.date }
    }
}

struct AchievementsSection: View {
    @EnvironmentObject var dataStore: AppDataStore
    
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
            
            if dataStore.statistics.badges.isEmpty {
                Text("Complete quests and maintain streaks to unlock badges!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    // Show all badges, most recent first
                    ForEach(Array(dataStore.statistics.badges.sorted(by: { $0.unlockedDate > $1.unlockedDate }))) { badge in
                        BadgeView(badge: badge)
                    }
                }
            }
        }
        .softCard(accent: .purple, cornerRadius: 28)
    }
}

struct HealthMilestonesSection: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    private let milestones = [
        (days: 1, title: "First Steps", description: "Heart rate and blood pressure drop"),
        (days: 3, title: "Nicotine Free", description: "Nicotine is completely out of your system"),
        (days: 7, title: "One Week Strong", description: "Taste and smell improve"),
        (days: 30, title: "One Month", description: "Lung function increases up to 30%"),
        (days: 90, title: "Three Months", description: "Circulation improves significantly"),
        (days: 365, title: "One Year", description: "Risk of heart disease cut in half")
    ]
    
    private var daysFromStartDate: Int {
        guard let startDate = dataStore.currentUser?.startDate else { return 0 }
        let elapsed = Date().timeIntervalSince(startDate)
        return max(0, Int(elapsed) / 86_400)
    }
    
    private var nextMilestone: (days: Int, title: String, description: String)? {
        milestones.first { daysFromStartDate < $0.days }
    }
    
    private var upcomingMilestones: [(days: Int, title: String, description: String)] {
        guard let next = nextMilestone else { return [] }
        let nextIndex = milestones.firstIndex { $0.days == next.days } ?? 0
        return Array(milestones.suffix(from: nextIndex + 1))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with title and "More" button
            HStack {
                Text("Your Milestones")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("More")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.45, green: 0.72, blue: 0.99), Color(red: 0.60, green: 0.80, blue: 1.0)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
            
            // Description text
            Text("Celebrate achievements as you progress through milestones, which represent significant points of growth.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 16) {
                // Next Milestone Card
                if let next = nextMilestone {
                    MilestoneCard(
                        label: "NEXT MILESTONE",
                        title: next.title,
                        daysFree: next.days,
                        isNext: true,
                        isCompleted: false,
                        currentDays: daysFromStartDate,
                        daysRequired: next.days
                    )
                }
                
                // Upcoming Milestones
                ForEach(upcomingMilestones, id: \.days) { milestone in
                    MilestoneCard(
                        label: "UPCOMING",
                        title: milestone.title,
                        daysFree: milestone.days,
                        isNext: false,
                        isCompleted: false,
                        currentDays: daysFromStartDate,
                        daysRequired: milestone.days
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct MilestoneCard: View {
    let label: String
    let title: String
    let daysFree: Int
    let isNext: Bool
    let isCompleted: Bool
    let currentDays: Int
    let daysRequired: Int
    
    private var progress: Double {
        guard daysRequired > 0 else { return 0 }
        return min(1.0, Double(currentDays) / Double(daysRequired))
    }
    
    private var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("\(daysFree) Days Free")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                // Progress bar for upcoming milestones
                if !isNext {
                    HStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(red: 0.45, green: 0.72, blue: 0.99))
                                    .frame(width: geometry.size.width * progress, height: 4)
                            }
                        }
                        .frame(height: 4)
                        
                        Text("\(progressPercentage)%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 35, alignment: .trailing)
                    }
                }
            }
            
            Spacer()
            
            // Icon square with lock
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.3),
                                Color.black.opacity(0.5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .blur(radius: 2)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(
            Group {
                if isNext {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.45, green: 0.72, blue: 0.99).opacity(0.15),
                            Color(red: 0.60, green: 0.80, blue: 1.0).opacity(0.1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    Color.white
                }
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let emoji: String
    let accentColor: Color
    let subtitle: String?
    
    init(title: String, value: String, emoji: String, accentColor: Color, subtitle: String? = nil) {
        self.title = title
        self.value = value
        self.emoji = emoji
        self.accentColor = accentColor
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Emoji icon - consistent size
            Text(emoji)
                .font(.system(size: 32))
            
            // Value - visual focus, larger and bold
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .monospacedDigit()
            
            // Title - clearly secondary
            Text(title.uppercased())
                .font(.caption)
                .kerning(0.5)
                .foregroundColor(.secondary)
            
            // Subtitle - restrained micro-copy
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(accentColor.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(accentColor.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
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
    @EnvironmentObject var dataStore: AppDataStore
    let timeFrame: ProgressView.TimeFrame
    
    // Primary accent color - same as app
    private let primaryAccentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Strong headline
            Text("Daily puff count")
                .font(.title2)
                .fontWeight(.bold)
            
            // Takeaway at the top - immediate insight
            if let todayProgress = todayProgress {
                HStack(spacing: 8) {
                    if todayProgress.puffInterval == .none {
                        Text("🎉")
                            .font(.title3)
                        Text("Vape-free day!")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(primaryAccentColor)
                    } else {
                        Text("📊")
                            .font(.title3)
                        Text("\(todayProgress.puffInterval.displayName) today")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(todayProgress.puffInterval == .none ? primaryAccentColor.opacity(0.1) : Color.gray.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(todayProgress.puffInterval == .none ? primaryAccentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                )
            }
            
            // Lighter explanatory text
            Text("Track your progress as puffs decrease over time.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Chart - secondary to insight
            if filteredProgressData.isEmpty {
                EmptyChartView(message: "No puff data available for this time period")
            } else {
                Chart(filteredProgressData, id: \.date) { progress in
                    BarMark(
                        x: .value("Date", progress.date),
                        y: .value("Puffs", progress.puffInterval.numericValue)
                    )
                    .foregroundStyle(progress.puffInterval == .none ? primaryAccentColor : primaryAccentColor.opacity(0.6))
                    .cornerRadius(4)
                }
                .frame(height: 180)
                .chartYScale(domain: chartYDomain)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: timeFrame == .week ? 1 : 7)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 4]))
                            .foregroundStyle(Color.gray.opacity(0.15))
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            .foregroundStyle(Color.secondary)
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 4]))
                            .foregroundStyle(Color.gray.opacity(0.15))
                        if let intValue = value.as(Int.self),
                           intValue >= 0 && intValue <= 4 {
                            AxisValueLabel {
                                if let interval = PuffInterval.allCases.first(where: { $0.numericValue == intValue }) {
                                    Text(interval == .none ? "0" : interval.shortName)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            
            // Stats row - game rewards style
            HStack(spacing: 24) {
                StatRewardCard(
                    label: "Most common",
                    value: mostCommonInterval.displayName,
                    isHighlight: false
                )
                
                StatRewardCard(
                    label: "Best day",
                    value: bestInterval.displayName,
                    isHighlight: bestInterval == .none
                )
                
                StatRewardCard(
                    label: "Vape-free",
                    value: "\(vapeFreeDays)",
                    isHighlight: vapeFreeDays > 0
                )
                
                Spacer()
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var todayProgress: DailyProgress? {
        return filteredProgressData.first { Calendar.current.isDateInToday($0.date) }
    }
    
    private var chartYDomain: ClosedRange<Int> {
        let maxValue = filteredProgressData.map { $0.puffInterval.numericValue }.max() ?? 0
        // If all values are zero, compress the domain to show zero prominently
        if maxValue == 0 {
            return 0...1
        }
        return 0...4
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
            startDate = dataStore.dailyProgress.first?.date ?? now
        }
        
        return dataStore.dailyProgress
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

struct StatRewardCard: View {
    let label: String
    let value: String
    let isHighlight: Bool
    
    private let primaryAccentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Number prominence - game reward style
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(isHighlight ? primaryAccentColor : .primary)
            
            // Reduced label weight
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .kerning(0.3)
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

struct MotivationTile: View {
    let emoji: String
    var accent: Color = .pink
    let message: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(emoji)
                .font(.system(size: 20))
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(accent.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
        )
    }
}

struct GoalProgressSection: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var currentDate = Date()
    @State private var selectedMonth = Date()
    @State private var timer: Timer?
    
    // Primary accent color - same as app
    private let primaryAccentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        VStack(spacing: 24) {
            // Goal Progress Card - answers: what day, how I'm doing, what's next
            VStack(alignment: .leading, spacing: 20) {
                // Today's date - secondary label
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Progress to Goal - PRIMARY FOCUS
                VStack(alignment: .leading, spacing: 12) {
                    // Large percentage as visual focus
                    Text("\(progressPercentage)%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                    
                    // Simplified label
                    Text("Progress to Goal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Progress bar - using app accent color
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(primaryAccentColor)
                                .frame(width: geometry.size.width * CGFloat(progressPercentage) / 100, height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    // Days count - secondary
                    Text("\(currentDays) of \(targetDays) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Divider
                Divider()
                    .padding(.vertical, 4)
                
                // Next Milestone - SECONDARY, motivating and concrete
                HStack(alignment: .center, spacing: 10) {
                    Text("Next Milestone")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(daysRemainingText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
            
            // Calendar Card
            VStack(spacing: 16) {
                // Calendar header - lighter
                HStack {
                    Button(action: { changeMonth(-1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: { changeMonth(1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 4)
                
                // Days of week - lighter
                HStack(spacing: 0) {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar grid - perfect spacing
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(calendarDays, id: \.id) { day in
                        CalendarDayView(
                            day: day,
                            isToday: isToday(day.date),
                            isStartDate: isStartDate(day.date),
                            isGoalDate: isGoalDate(day.date),
                            isInProgressRange: isInProgressRange(day.date),
                            accentColor: primaryAccentColor
                        )
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
        }
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
        dataStore.daysSinceQuitStartDate()
    }
    
    private var targetDays: Int {
        dataStore.currentUser?.quitGoal.targetDays ?? 30
    }
    
    private var progressPercentage: Int {
        guard targetDays > 0 else { return 0 }
        return min(100, Int((Double(currentDays) / Double(targetDays)) * 100))
    }
    
    private var daysRemainingText: String {
        let daysRemaining = max(0, targetDays - currentDays)
        if daysRemaining == 0 {
            return "Goal reached!"
        } else if daysRemaining == 1 {
            return "1 day remaining"
        } else {
            return "\(daysRemaining) days remaining"
        }
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
        guard let startDate = dataStore.currentUser?.startDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: startDate)
    }
    
    private func isGoalDate(_ date: Date) -> Bool {
        guard let startDate = dataStore.currentUser?.startDate,
              let goalDate = Calendar.current.date(byAdding: .day, value: targetDays, to: startDate) else {
            return false
        }
        return Calendar.current.isDate(date, inSameDayAs: goalDate)
    }
    
    private func isInProgressRange(_ date: Date) -> Bool {
        guard let startDate = dataStore.currentUser?.startDate else { return false }
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
    let accentColor: Color
    
    var body: some View {
        Text("\(day.dayNumber)")
            .font(.system(size: 15, weight: isToday ? .semibold : .regular))
            .foregroundColor(dayColor)
            .frame(width: 36, height: 36)
            .background(backgroundShape)
            .frame(maxWidth: .infinity)
    }
    
    private var dayColor: Color {
        if !day.isCurrentMonth {
            return .gray.opacity(0.25)
        } else if isToday {
            return .primary
        } else if isInProgressRange {
            return .primary
        } else {
            return .primary
        }
    }
    
    @ViewBuilder
    private var backgroundShape: some View {
        if isToday {
            // Today - clearly highlighted but neutral
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        } else if isInProgressRange && day.isCurrentMonth {
            // Completed days - soft filled background
            RoundedRectangle(cornerRadius: 8)
                .fill(accentColor.opacity(0.12))
        } else if isGoalDate && day.isCurrentMonth {
            // Goal date - subtle accent
            RoundedRectangle(cornerRadius: 8)
                .fill(accentColor.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(accentColor.opacity(0.3), lineWidth: 1)
                )
        } else {
            // Future days - minimal
            Color.clear
        }
    }
}

#Preview {
    ProgressView()
        .environmentObject(AppDataStore())
}
