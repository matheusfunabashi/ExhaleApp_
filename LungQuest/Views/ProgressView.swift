import SwiftUI
import Charts

struct ProgressView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @EnvironmentObject var flowManager: AppFlowManager
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
            .onAppear {
                // Request review if conditions are met
                ReviewManager.shared.requestReviewIfNeeded(
                    onboardingCompleted: !flowManager.isOnboarding,
                    hasOpenedProgressView: true,
                    hasCompletedCheckIn: false
                )
            }
        }
        .navigationViewStyle(.stack)
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
                    value: dataStore.formattedMoneySaved(),
                    emoji: "💰",
                    accentColor: Color(red: 0.2, green: 0.6, blue: 0.9), // Soft blue
                    subtitle: "Keep it up!"
                )
                
                StatCard(
                    title: "Longest Streak",
                    value: "\(dataStore.currentUser?.quitGoal.longestStreak ?? 0)",
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
                    title: "Milestones",
                    value: "\(dataStore.statistics.completedQuests)",
                    emoji: "🎯",
                    accentColor: Color(red: 0.9, green: 0.5, blue: 0.6), // Soft pink
                    subtitle: "Achievements unlocked"
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
    
    private var savingsHighlight: (emoji: String, message: String, color: Color)? {
        let savings = dataStore.moneySavedFromFirstQuit()
        switch savings {
        case ..<5:
            return ("🍃", "Every bit counts—\(dataStore.formattedMoneySaved()) saved already is a fresh start fund.", Color.green)
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
            // Header with title
            Text("Your Milestones")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
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

// MARK: - Chart day slot: one per day in range; progress nil = no check-in
private struct PuffChartDaySlot: Identifiable {
    let id: Date
    let date: Date
    let progress: DailyProgress?
}

// MARK: - Vertical bar chart: X = all days, Y = discrete puff levels; 0 puffs = tick, no data = placeholder
private struct PuffBarChart: View {
    let slots: [PuffChartDaySlot]
    let maxY: Int
    let primaryAccentColor: Color
    
    private static let yLevels: [(label: String, level: Int)] = [
        ("0", 0),
        ("1–10", 1),
        ("11–30", 2),
        ("31–60", 3),
        ("61+", 4)
    ]
    private static let levelCount: Int = 5
    private let weekdayFormat: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()
    
    private let plotHeight: CGFloat = 120
    private let barCornerRadius: CGFloat = 5
    private let barSpacing: CGFloat = 6
    private let tickHeight: CGFloat = 4
    private let placeholderHeight: CGFloat = 4
    
    var body: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        HStack(alignment: .bottom, spacing: 0) {
            // Y-axis labels (discrete levels), aligned to grid
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(Array(Self.yLevels.enumerated().reversed()), id: \.element.level) { idx, item in
                    Text(item.label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.85))
                        .lineLimit(1)
                    if idx < Self.yLevels.count - 1 {
                        Spacer()
                            .frame(height: max(0, plotHeight / CGFloat(Self.levelCount) - 1))
                    }
                }
            }
            .frame(height: plotHeight)
            .frame(width: 28)
            .padding(.trailing, 6)
            
            // Chart area: grid + bars + X-axis
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    // Soft horizontal grid at each discrete level
                    VStack(spacing: 0) {
                        ForEach(0..<Self.levelCount, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.08))
                                .frame(height: 1)
                            Spacer()
                                .frame(height: max(0, plotHeight / CGFloat(Self.levelCount) - 1))
                        }
                    }
                    .frame(height: plotHeight)
                    
                    // One visual per day: bar, tick (0 puffs), or placeholder (no check-in); bars slightly narrower
                    HStack(alignment: .bottom, spacing: barSpacing) {
                        ForEach(slots) { slot in
                            dayBarView(date: slot.date, progress: slot.progress, today: today, calendar: calendar)
                                .padding(.horizontal, 3)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(height: plotHeight)
                
                // X-axis: day labels (all days)
                HStack(spacing: barSpacing) {
                    ForEach(slots) { slot in
                        Text(weekdayFormat.string(from: slot.date))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.9))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private func dayBarView(date: Date, progress: DailyProgress?, today: Date, calendar: Calendar) -> some View {
        let isToday = calendar.isDate(date, inSameDayAs: today)
        
        if let progress = progress {
            let level = progress.puffInterval.numericValue
            if level == 0 {
                // 0 puffs: small visible tick at baseline (distinct from no-data)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.25, green: 0.65, blue: 0.45))
                    .frame(height: tickHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .strokeBorder(isToday ? Color.primary.opacity(0.15) : Color.clear, lineWidth: 1)
                    )
            } else {
                // >0 puffs: filled bar (softer, narrower)
                let heightRatio = CGFloat(level + 1) / CGFloat(Self.levelCount)
                let barHeight = max(4, plotHeight * heightRatio)
                let barColor = barColorForLevel(level, isToday: isToday)
                RoundedRectangle(cornerRadius: barCornerRadius)
                    .fill(barColor)
                    .frame(height: barHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: barCornerRadius)
                            .strokeBorder(isToday ? Color.primary.opacity(0.18) : Color.clear, lineWidth: 1)
                    )
            }
        } else {
            // No check-in: neutral placeholder at baseline (outline, distinct from 0 puffs)
            RoundedRectangle(cornerRadius: 2)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                .foregroundColor(Color.gray.opacity(0.35))
                .frame(height: placeholderHeight)
        }
    }
    
    private func barColorForLevel(_ level: Int, isToday: Bool) -> Color {
        // Use same blue as "Best day" / "0 puffs" text (primaryAccentColor) for consistency
        let opacity = level == 0 ? 0.75 : (0.58 + Double(level) * 0.06)
        let color = primaryAccentColor.opacity(opacity)
        return isToday ? color.opacity(0.95) : color
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
            
            // Chart: all days in range get a visual (bar, 0-puff tick, or no-check-in placeholder)
            if chartDaySlots.isEmpty {
                EmptyChartView(message: "No days in this time period")
            } else {
                PuffBarChart(
                    slots: chartDaySlots,
                    maxY: chartYMax,
                    primaryAccentColor: primaryAccentColor
                )
                .frame(height: chartContentHeight)
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
    
    /// Y-axis cap: user's recent max so chart isn't dominated by empty space (no fixed 61+).
    private var chartYMax: Int {
        let maxValue = filteredProgressData.map { $0.puffInterval.numericValue }.max() ?? 0
        return max(1, maxValue)
    }
    
    /// Height fits content (no tall empty area when values are low).
    private var chartContentHeight: CGFloat {
        let maxVal = chartYMax
        if maxVal <= 1 { return 118 }
        if maxVal <= 2 { return 130 }
        return 145
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
    
    /// All days in the current time range, each with optional progress (nil = no check-in). Used so every day has a visual.
    private var chartDaySlots: [PuffChartDaySlot] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        let endDate = calendar.startOfDay(for: now)
        switch timeFrame {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate) ?? endDate
        case .all:
            startDate = dataStore.dailyProgress.first.map { calendar.startOfDay(for: $0.date) } ?? calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
        }
        var slots: [PuffChartDaySlot] = []
        var current = startDate
        while current <= endDate {
            let progress = dataStore.dailyProgress.first { calendar.isDate($0.date, inSameDayAs: current) }
            slots.append(PuffChartDaySlot(id: current, date: current, progress: progress))
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return slots
    }
    
    /// On tie for most common count, pick the lowest puff level (0 puffs before 1–10, etc.) so the UI doesn’t flip.
    private var mostCommonInterval: PuffInterval {
        guard !filteredProgressData.isEmpty else { return .none }
        let intervalCounts = Dictionary(grouping: filteredProgressData, by: { $0.puffInterval })
        let maxCount = intervalCounts.values.map(\.count).max() ?? 0
        let tied = intervalCounts.filter { $0.value.count == maxCount }.keys
        return tied.min(by: { $0.numericValue < $1.numericValue }) ?? .none
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
            ProgressCalendarView()
        }
        .onAppear {
            currentDate = Date()
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
    
}

struct ProgressCalendarView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedMonth = Date()
    @State private var selectedCheckIn: DailyProgress? = nil
    
    // Primary accent color - same as app
    private let primaryAccentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
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
                        accentColor: primaryAccentColor,
                        hasCheckIn: hasCheckIn(on: day.date),
                        onTap: {
                            if let checkIn = getCheckIn(for: day.date) {
                                selectedCheckIn = checkIn
                            }
                        }
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
        .sheet(item: Binding(
            get: { selectedCheckIn },
            set: { selectedCheckIn = $0 }
        )) { checkIn in
            CheckInDetailView(checkIn: checkIn)
                .environmentObject(dataStore)
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
              let targetDays = dataStore.currentUser?.quitGoal.targetDays,
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
    
    private func hasCheckIn(on date: Date) -> Bool {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        return dataStore.dailyProgress.contains { progress in
            calendar.isDate(progress.date, inSameDayAs: dayStart)
        }
    }
    
    private func getCheckIn(for date: Date) -> DailyProgress? {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        return dataStore.dailyProgress.first { progress in
            calendar.isDate(progress.date, inSameDayAs: dayStart)
        }
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
    let hasCheckIn: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Text("\(day.dayNumber)")
                    .font(.system(size: 15, weight: isToday ? .semibold : .regular))
                    .foregroundColor(dayColor)
                    .frame(width: 36, height: 36)
                    .background(backgroundShape)
                
                // Green checkmark overlay
                if hasCheckIn {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.green)
                                .padding(.trailing, 2)
                                .padding(.bottom, 2)
                        }
                    }
                    .frame(width: 36, height: 36)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
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

struct CheckInDetailView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.presentationMode) var presentationMode
    let checkIn: DailyProgress
    
    private let accentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: checkIn.date)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    // Header - clearer hierarchy
                    VStack(spacing: 6) {
                        Text("Check-in Details")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(formattedDate)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                    
                    // Vape-free status
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Status")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 10) {
                            Image(systemName: checkIn.wasVapeFree ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(checkIn.wasVapeFree ? .green : .red)
                                .font(.system(size: 20, weight: .medium))
                            
                            Text(checkIn.wasVapeFree ? "Vape-free day! 🎉" : "Not vape-free")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(checkIn.wasVapeFree ? Color.green.opacity(0.08) : Color.red.opacity(0.08))
                        )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.75)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(accentColor.opacity(0.12), lineWidth: 1)
                                    .blendMode(.overlay)
                            )
                            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                            .shadow(color: accentColor.opacity(0.08), radius: 16, x: 0, y: 10)
                    )
                    
                    // Cravings level
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cravings Level")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 8) {
                                ForEach(1...5, id: \.self) { level in
                                    Circle()
                                        .fill(
                                            level <= checkIn.cravingsLevel
                                                ? cravingsColor(level).opacity(0.85)
                                                : Color.gray.opacity(0.12)
                                        )
                                        .frame(width: 38, height: 38)
                                        .overlay(
                                            Text("\(level)")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(level <= checkIn.cravingsLevel ? .white : .secondary)
                                        )
                                }
                            }
                            
                            Text(cravingsDescription)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .lineSpacing(2)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.gray.opacity(0.06))
                        )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.75)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(accentColor.opacity(0.12), lineWidth: 1)
                                    .blendMode(.overlay)
                            )
                            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                            .shadow(color: accentColor.opacity(0.08), radius: 16, x: 0, y: 10)
                    )
                    
                    // Mood
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mood")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            Text(checkIn.mood.emoji)
                                .font(.system(size: 28))
                            Text(checkIn.mood.rawValue.capitalized)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(checkIn.mood.color.opacity(0.08))
                        )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.75)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(accentColor.opacity(0.12), lineWidth: 1)
                                    .blendMode(.overlay)
                            )
                            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                            .shadow(color: accentColor.opacity(0.08), radius: 16, x: 0, y: 10)
                    )
                    
                    // Puff count
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Puff Count")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(checkIn.puffInterval.displayName)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(checkIn.puffInterval.color.opacity(0.08))
                            )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.75)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(accentColor.opacity(0.12), lineWidth: 1)
                                    .blendMode(.overlay)
                            )
                            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                            .shadow(color: accentColor.opacity(0.08), radius: 16, x: 0, y: 10)
                    )
                    
                    // Notes
                    if !checkIn.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notes")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(checkIn.notes)
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .lineSpacing(4)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.gray.opacity(0.06))
                                )
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.75)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(accentColor.opacity(0.12), lineWidth: 1)
                                        .blendMode(.overlay)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                                .shadow(color: accentColor.opacity(0.08), radius: 16, x: 0, y: 10)
                        )
                    }
                    
                    Spacer(minLength: 12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(accentColor)
            )
            .breathableBackground()
        }
        .navigationViewStyle(.stack)
    }
    
    private func cravingsColor(_ level: Int) -> Color {
        switch level {
        case 1: return Color(red: 0.20, green: 0.70, blue: 0.35)
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.25)
        case 3: return Color(red: 0.95, green: 0.60, blue: 0.20)
        case 4: return Color(red: 0.90, green: 0.40, blue: 0.30)
        case 5: return Color(red: 0.80, green: 0.25, blue: 0.35)
        default: return Color.gray
        }
    }
    
    private var cravingsDescription: String {
        switch checkIn.cravingsLevel {
        case 1: return "No cravings at all! ✨"
        case 2: return "Mild thoughts, easily ignored"
        case 3: return "Noticeable but manageable"
        case 4: return "Strong urges, required effort"
        case 5: return "Very intense, difficult to resist"
        default: return ""
        }
    }
}

#Preview {
    ProgressView()
        .environmentObject(AppDataStore())
}
