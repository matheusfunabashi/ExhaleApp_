import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showEditProfile = false
    @State private var showExportData = false
    @State private var showShareStreak = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header with user info
                    ProfileHeaderSection()
                    
                    ProfileSection(
                        title: "Your journey",
                        subtitle: "Celebrate streaks, savings, and badges at a glance."
                    ) {
                        QuickStatsSection(onCurrentStreakTap: { showShareStreak = true })
                    }
                    
                    ProfileSection(
                        title: "Milestones & rewards",
                        subtitle: "See how your XP and streak open new surprises."
                    ) {
                        ProgressionRewardsSection()
                    }
                    
                    if appState.statistics.badges.count > 0 {
                        ProfileSection(
                            title: "Achievements",
                            subtitle: "Recent badges cheering you on."
                        ) {
                            BadgeShowcaseSection()
                        }
                    }
                    
                    ProfileSection(
                        title: "Reminders & preferences",
                        subtitle: "Tune notifications and daily support rituals."
                    ) {
                        SettingsSection()
                    }
                    
                    ProfileSection(
                        title: "Data & support",
                        subtitle: "Export your progress or find the help you need."
                    ) {
                        VStack(spacing: 18) {
                            DataManagementSectionWrapper(showExportData: $showExportData)
                            Divider().padding(.vertical, 4)
                            AppInfoSection()
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarItems(
                trailing: Button("Edit") {
                    showEditProfile = true
                }
            )
            .breathableBackground()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .preferredColorScheme(.light)
        }
        .sheet(isPresented: $showExportData) {
            ExportDataView()
                .preferredColorScheme(.light)
        }
        .sheet(isPresented: $showShareStreak) {
            ShareStreakView(isPresented: $showShareStreak)
                .environmentObject(appState)
                .preferredColorScheme(.light)
        }
    }
}

struct ProfileHeaderSection: View {
    @EnvironmentObject var appState: AppState
    
    private var daysFromStartDate: Int {
        guard let startDate = appState.currentUser?.startDate else { return 0 }
        let elapsed = Date().timeIntervalSince(startDate)
        return max(0, Int(elapsed) / 86_400)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                avatarView
                Spacer(minLength: 12)
                ProfileLungBuddyView(healthLevel: appState.lungState.healthLevel)
                    .frame(width: 128)
                    .padding(.trailing, 4)
                    .overlay(alignment: .topTrailing) {
                        moodBadge
                    }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(appState.currentUser?.name ?? "User")
                    .font(.title2.weight(.bold))
                
                Text("Level \(appState.statistics.currentLevel) • \(daysFromStartDate) days strong")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let startDate = appState.currentUser?.startDate {
                    Text("Journey started \(startDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(lungMoodCopy)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(Color(red: 0.16, green: 0.36, blue: 0.87))
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Lung Health")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(appState.lungState.healthLevel)%")
                            .font(.caption2.bold())
                            .foregroundColor(.primary)
                    }
                    SwiftUI.ProgressView(value: Double(appState.lungState.healthLevel), total: 100)
                        .tint(.green)
                        .accessibilityLabel("Lung health progress")
                        .accessibilityValue("\(appState.lungState.healthLevel) percent")
                }
            }
        }
        .softCard(accent: headerAccentColor, cornerRadius: 32)
    }
    
    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.pink.opacity(0.35), Color.blue.opacity(0.25)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 84, height: 84)
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
            Text(userInitials)
                .font(.title.weight(.bold))
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.55), lineWidth: 3)
        )
    }
    
    private var moodBadge: some View {
        Text(moodEmoji)
            .font(.title3)
            .padding(8)
            .background(
                Circle()
                    .fill(headerAccentColor.opacity(0.18))
                    .overlay(
                        Circle()
                            .stroke(headerAccentColor.opacity(0.4), lineWidth: 1.5)
                    )
                    .shadow(color: headerAccentColor.opacity(0.35), radius: 10, x: 0, y: 6)
            )
            .offset(x: 10, y: -10)
    }
    
    private var lungMoodCopy: String {
        let level = appState.lungState.healthLevel
        switch level {
        case 0..<25:
            return "Let’s help your lungs feel lighter today."
        case 25..<50:
            return "Fresh air is flowing back in—keep up the gentle wins."
        case 50..<75:
            return "Your lungs feel brighter with every check-in."
        default:
            return "Your lungs are glowing—deep breaths feel amazing!"
        }
    }
    
    private var moodEmoji: String {
        let level = appState.lungState.healthLevel
        switch level {
        case 0..<25: return "🌧"
        case 25..<50: return "🌤"
        case 50..<75: return "😊"
        default: return "🌞"
        }
    }

    private var headerAccentColor: Color {
        let level = appState.lungState.healthLevel
        switch level {
        case 0..<25: return Color(red: 0.84, green: 0.41, blue: 0.46)
        case 25..<50: return Color(red: 0.67, green: 0.52, blue: 0.93)
        case 50..<75: return Color(red: 0.38, green: 0.63, blue: 0.97)
        default: return Color(red: 0.26, green: 0.67, blue: 0.61)
        }
    }
    
    private var userInitials: String {
        let name = appState.currentUser?.name ?? "U"
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        } else {
            return String(name.prefix(1)).uppercased()
        }
    }
}

struct QuickStatsSection: View {
    @EnvironmentObject var appState: AppState
    var onCurrentStreakTap: (() -> Void)? = nil
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            QuickStatCard(
                title: "Current Streak",
                value: "\(daysFromStartDate) days",
                emoji: "🔥",
                color: .orange,
                onTap: onCurrentStreakTap
            )
            
            QuickStatCard(
                title: "Best Streak",
                value: "\(longestStreakFromStartDate) days",
                emoji: "🏆",
                color: .orange.opacity(0.9)
            )
            
            QuickStatCard(
                title: "Money Saved",
                value: String(format: "$%.0f", moneySavedFromStartDate),
                emoji: "💰",
                color: .blue
            )
            
            QuickStatCard(
                title: "Badges Earned",
                value: "\(appState.statistics.badges.count)",
                emoji: "⭐",
                color: .purple
            )
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
}

struct ProgressionRewardsSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Level \(appState.statistics.currentLevel)")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(appState.statistics.totalXP) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                SwiftUI.ProgressView(value: xpProgress, total: 100)
                    .tint(progressAccent)
                Text("\(xpToNextLevel) XP until Level \(appState.statistics.currentLevel + 1)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 12) {
                RewardChip(icon: "medal.fill", title: "Rewards unlocked", subtitle: nextRewardSummary, color: .yellow)
                RewardChip(icon: "flame", title: "Streak momentum", subtitle: streakMessage, color: .orange)
                RewardChip(icon: "star.circle", title: "Badge showcase", subtitle: badgeMessage, color: .purple)
            }
        }
    }
    
    private var xpProgress: Double {
        let currentLevelXP = max(0, (appState.statistics.currentLevel - 1) * 100)
        let progressInLevel = appState.statistics.totalXP - currentLevelXP
        return Double(max(0, min(100, progressInLevel)))
    }
    
    private var xpToNextLevel: Int {
        let target = appState.statistics.currentLevel * 100
        return max(0, target - appState.statistics.totalXP)
    }
    
    private var badgeMessage: String {
        let count = appState.statistics.badges.count
        switch count {
        case 0:
            return "Complete quests or streaks to earn your first badge."
        case 1:
            return "You’ve earned your first badge—more await as you stay steady."
        case 2...5:
            return "\(count) badges collected; consistency is building your trophy shelf."
        default:
            return "Your badge gallery is glowing—keep sharing those wins."
        }
    }
    
    private var nextRewardSummary: String {
        let nextLevel = appState.statistics.currentLevel + 1
        switch nextLevel {
        case 2:
            return "Unlock a calming breathing quest at Level 2."
        case 3:
            return "Level 3 reveals a gratitude journal prompt."
        case 4:
            return "Earn a golden badge background at Level 4."
        default:
            return "Level \(nextLevel) unlocks a surprise self-care reward."
        }
    }
    
    private var streakMessage: String {
        let days = daysFromStartDate
        switch days {
        case ..<1:
            return "Your restart is ready—today counts."
        case 1...6:
            return "Early momentum! \(days) day streak is just the beginning."
        case 7...29:
            return "\(days) days strong—weekly badges love this consistency."
        case 30...89:
            return "Monthly streak magic! Your lungs feel the lift."
        default:
            return "Long-haul streak legend—your resilience lights the way."
        }
    }
    
    private var daysFromStartDate: Int {
        guard let startDate = appState.currentUser?.startDate else { return 0 }
        let elapsed = Date().timeIntervalSince(startDate)
        return max(0, Int(elapsed) / 86_400)
    }
    
    private var rewardTagline: String {
        if xpToNextLevel == 0 {
            return "Level up complete—new celebrations unlocked!"
        } else {
            return "Every check-in adds XP towards calming rewards."
        }
    }
    
    private var progressAccent: Color {
        let currentLevel = appState.statistics.currentLevel
        switch currentLevel {
        case 1:
            return Color(red: 0.84, green: 0.41, blue: 0.46)
        case 2:
            return Color(red: 0.67, green: 0.52, blue: 0.93)
        case 3:
            return Color(red: 0.38, green: 0.63, blue: 0.97)
        default:
            return Color(red: 0.26, green: 0.67, blue: 0.61)
        }
    }
}

struct SettingsSection: View {
    @EnvironmentObject var appState: AppState
    @State private var notificationsEnabled = true
    @State private var selectedReminderFreq = ReminderFrequency.daily
    
    var body: some View {
        VStack(spacing: 14) {
            SettingsRow(
                icon: "bell.fill",
                title: "Push Notifications",
                color: Color(red: 0.31, green: 0.57, blue: 0.99)
            ) {
                Toggle("", isOn: $notificationsEnabled)
                    .labelsHidden()
                    .tint(Color(red: 0.31, green: 0.57, blue: 0.99))
            }
            
            SettingsRow(
                icon: "clock.fill",
                title: "Reminder Frequency",
                color: .orange
            ) {
                Menu {
                    ForEach(ReminderFrequency.allCases, id: \.self) { freq in
                        Button(freq.rawValue.capitalized) {
                            selectedReminderFreq = freq
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(selectedReminderFreq.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.6))
                    )
                }
            }
            
            SettingsRow(
                icon: "moon.fill",
                title: "Dark Mode",
                color: .indigo
            ) {
                Text("System")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            notificationsEnabled = appState.currentUser?.profile.preferences.notificationsEnabled ?? true
            selectedReminderFreq = appState.currentUser?.profile.preferences.reminderFrequency ?? .daily
        }
    }
}

struct DataManagementSection: View {
    @Binding var showExportData: Bool
    
    var body: some View {
        DataActionRow(
            icon: "square.and.arrow.up",
            title: "Export Data",
            subtitle: "Download your progress as PDF",
            color: .green,
            action: { showExportData = true }
        )
    }
}

struct AppInfoSection: View {
    var body: some View {
        VStack(spacing: 14) {
            InfoRow(title: "Version", value: "1.0.0")
            InfoRow(title: "Build", value: "001")
            
            Divider()
                .padding(.vertical, 4)
            
            NavigationLink(destination: SupportView()) {
                InfoLinkRow(icon: "questionmark.circle.fill", iconColor: .blue, title: "Help & Support")
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: PrivacyPolicyView()) {
                InfoLinkRow(icon: "lock.shield.fill", iconColor: .green, title: "Privacy Policy")
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let emoji: String
    let color: Color
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        let content = VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .leading) {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.35), color.opacity(0.15)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.25), lineWidth: 1)
                    )
                Text(emoji)
                    .font(.system(size: 24))
                    .offset(x: 10)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(value)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                Text(title.uppercased())
                    .font(.caption2)
                    .kerning(0.8)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard(accent: color, cornerRadius: 26)
        
        if let onTap = onTap {
            Button(action: onTap) { content }
                .buttonStyle(PlainButtonStyle())
        } else {
            content
        }
    }
}

private struct ProfileSection<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content
    
    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.capitalized)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            content
        }
        .softCard(accent: Color(red: 0.31, green: 0.57, blue: 0.99), cornerRadius: 28)
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: Content
    
    init(icon: String, title: String, color: Color, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.16))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(color.opacity(0.25), lineWidth: 1)
                    )
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.headline)
            }
            
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            content
        }
        .padding(.vertical, 6)
    }
}

struct DataActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color.opacity(0.18))
                        .frame(width: 48, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(color.opacity(0.25), lineWidth: 1)
                        )
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.headline)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Circle()
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.secondary)
                    )
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct BadgeShowcaseSection: View {
    @EnvironmentObject var appState: AppState
    
    private var badges: [Badge] {
        Array(appState.statistics.badges.suffix(6)).reversed()
    }
    
    var body: some View {
        if badges.isEmpty {
            Text("Keep checking in to unlock your first badge.")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3), spacing: 14) {
                ForEach(badges) { badge in
                    BadgeChip(badge: badge)
                }
            }
        }
    }
}

private struct BadgeChip: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.icon)
                .font(.title3)
                .foregroundColor(.yellow)
                .padding(10)
                .background(
                    Circle()
                        .fill(Color.yellow.opacity(0.15))
                        .overlay(
                            Circle()
                                .stroke(Color.yellow.opacity(0.25), lineWidth: 1)
                        )
                )
            VStack(spacing: 2) {
                Text(badge.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                Text(badge.unlockedDate, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.6))
        )
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}

private struct InfoLinkRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconColor.opacity(0.16))
                    .frame(width: 46, height: 46)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(iconColor.opacity(0.25), lineWidth: 1)
                    )
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.headline)
            }
            
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Circle()
                .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                .frame(width: 26, height: 26)
                .overlay(
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.secondary)
                )
        }
        .padding(.vertical, 6)
    }
}

private struct RewardChip: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.18))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(color.opacity(0.25), lineWidth: 1)
                    )
                Image(systemName: icon)
                    .foregroundColor(color.opacity(0.9))
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }
}

// Local, size-adaptive LungBuddy for ProfileView usage
struct ProfileLungBuddyView: View {
    let healthLevel: Int
    @State private var bob: Bool = false
    
    private var bucketedLevel: Int {
        let clamped = max(0, min(100, healthLevel))
        let buckets: [Int] = [0, 25, 50, 75, 100]
        return buckets.min(by: { abs($0 - clamped) < abs($1 - clamped) }) ?? 0
    }
    
    private var assetName: String { "LungBuddy_\(bucketedLevel)" }
    
    var body: some View {
        Group {
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
            } else {
                LungCharacter(healthLevel: healthLevel, isAnimating: true)
            }
        }
        .aspectRatio(220.0/176.0, contentMode: .fit)
        .offset(y: bob ? -3 : 3)
        .animation(.easeInOut(duration: animationDuration).repeatForever(autoreverses: true), value: bob)
        .onAppear { bob = true }
        .accessibilityLabel("LungBuddy health image for level \(bucketedLevel)")
    }
    
    private var animationDuration: Double {
        let base = 2.0
        let factor = 1.2 - (Double(healthLevel) / 100.0)
        return max(0.9, base * factor)
    }
}

// MARK: - Supporting Views
struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var dailyCost = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
                
                Section("Vaping Information") {
                    TextField("Daily Cost ($)", text: $dailyCost)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveChanges()
                }
            )
        }
        .onAppear {
            loadCurrentData()
        }
    }
    
    private func loadCurrentData() {
        name = appState.currentUser?.name ?? ""
        email = appState.currentUser?.email ?? ""
        dailyCost = String(appState.currentUser?.profile.vapingHistory.dailyCost ?? 0)
    }
    
    private func saveChanges() {
        // Update user data
        // In a real app, this would update Firebase
        presentationMode.wrappedValue.dismiss()
    }
}

struct ExportDataView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Your Data")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Generate a PDF report of your progress to share with healthcare providers.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Button("Generate PDF Report") {
                    // Handle PDF generation
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Spacer()
            }
            .padding()
            .navigationBarItems(
                trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Share Streak Card
struct ShareStreakView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ShareStreakCard()
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                    .shadow(radius: 8)
                    .padding()
                
                Button(action: { isPresented = false }) {
                    Text("Close")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink))
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Share Your Streak")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct ShareStreakCard: View {
    @EnvironmentObject var appState: AppState
    private var name: String { appState.currentUser?.name ?? "LungQuest" }
    
    private var days: Int {
        guard let startDate = appState.currentUser?.startDate else { return 0 }
        let elapsed = Date().timeIntervalSince(startDate)
        return max(0, Int(elapsed) / 86_400)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(name)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("@LungQuest")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Vape‑Free Streak")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(days) day\(days == 1 ? "" : "s")")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            .padding(.vertical, 6)
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Scan to start your journey")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("lungquest.app")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                // Placeholder QR code
                QRPlaceholder()
                    .frame(width: 72, height: 72)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.1), Color.blue.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        )
    }
}

private struct QRPlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                .foregroundColor(.secondary)
            Image(systemName: "qrcode")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
}

struct SupportView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Help & Support")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Need assistance? We're here to help!")
                    .foregroundColor(.secondary)
                
                // FAQ section
                Text("Frequently Asked Questions")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                // Support contact
                Text("Contact Support")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Email: support@lungquest.app")
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your privacy is important to us. This policy explains how we handle your data.")
                    .foregroundColor(.secondary)
                
                Text("Data Collection")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("We only collect data necessary to provide our services and help you track your progress.")
                
                Text("Data Usage")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Your data is used solely for app functionality and is never shared with third parties.")
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Helper wrapper for DataManagementSection
struct DataManagementSectionWrapper: View {
    @Binding var showExportData: Bool
    
    var body: some View {
        DataManagementSection(showExportData: $showExportData)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
