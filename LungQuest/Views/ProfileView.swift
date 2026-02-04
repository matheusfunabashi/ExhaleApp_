import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showEditProfile = false
    
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
                        QuickStatsSection()
                    }
                    
                    if dataStore.statistics.badges.count > 0 {
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
                        subtitle: "Find the help you need."
                    ) {
                        AppInfoSection()
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
                .environmentObject(dataStore)
        }
    }
}

struct ProfileHeaderSection: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    private var daysFromStartDate: Int {
        guard let startDate = dataStore.currentUser?.startDate else { return 0 }
        let elapsed = Date().timeIntervalSince(startDate)
        return max(0, Int(elapsed) / 86_400)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
                avatarView
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(dataStore.currentUser?.name ?? "User")
                    .font(.title2.weight(.bold))
                
                Text("Level \(dataStore.statistics.currentLevel) • \(daysFromStartDate) days strong")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let startDate = dataStore.currentUser?.startDate {
                    Text("Journey started \(startDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(lungMoodCopy)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(Color(red: 0.45, green: 0.72, blue: 0.99))
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Lung Health")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(dataStore.lungState.healthLevel)%")
                            .font(.caption2.bold())
                            .foregroundColor(.primary)
                    }
                    SwiftUI.ProgressView(value: Double(dataStore.lungState.healthLevel), total: 100)
                        .tint(.green)
                        .accessibilityLabel("Lung health progress")
                        .accessibilityValue("\(dataStore.lungState.healthLevel) percent")
                }
            }
        }
        .softCard(accent: headerAccentColor, cornerRadius: 32)
    }
    
    private var avatarView: some View {
        Group {
            if let imageData = dataStore.currentUser?.profile.preferences.profilePictureData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 84, height: 84)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.55), lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
            } else {
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
        }
    }
    
    private var lungMoodCopy: String {
        let level = dataStore.lungState.healthLevel
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
        let level = dataStore.lungState.healthLevel
        switch level {
        case 0..<25: return "🌧"
        case 25..<50: return "🌤"
        case 50..<75: return "😊"
        default: return "🌞"
        }
    }

    private var headerAccentColor: Color {
        let level = dataStore.lungState.healthLevel
        switch level {
        case 0..<25: return Color(red: 0.84, green: 0.41, blue: 0.46)
        case 25..<50: return Color(red: 0.67, green: 0.52, blue: 0.93)
        case 50..<75: return Color(red: 0.38, green: 0.63, blue: 0.97)
        default: return Color(red: 0.26, green: 0.67, blue: 0.61)
        }
    }
    
    private var userInitials: String {
        let name = dataStore.currentUser?.name ?? "U"
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        } else {
            return String(name.prefix(1)).uppercased()
        }
    }
}

struct QuickStatsSection: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            QuickStatCard(
                title: "Current Streak",
                value: "\(daysFromStartDate) days",
                emoji: "🔥",
                color: .orange
            )
            
            QuickStatCard(
                title: "Best Streak",
                value: "\(dataStore.currentUser?.quitGoal.longestStreak ?? 0) days",
                emoji: "🏆",
                color: .orange.opacity(0.9)
            )
            
            QuickStatCard(
                title: "Money Saved",
                value: dataStore.formattedMoneySaved(),
                emoji: "💰",
                color: .blue
            )
            
            QuickStatCard(
                title: "Badges Earned",
                value: "\(dataStore.statistics.badges.count)",
                emoji: "⭐",
                color: .purple
            )
        }
    }
    
    private var daysFromStartDate: Int {
        guard let startDate = dataStore.currentUser?.startDate else { return 0 }
        let elapsed = Date().timeIntervalSince(startDate)
        return max(0, Int(elapsed) / 86_400)
    }
    
}

struct ProgressionRewardsSection: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Level \(dataStore.statistics.currentLevel)")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(dataStore.statistics.totalXP) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                SwiftUI.ProgressView(value: xpProgress, total: 100)
                    .tint(progressAccent)
                Text("\(xpToNextLevel) XP until Level \(dataStore.statistics.currentLevel + 1)")
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
        let currentLevelXP = max(0, (dataStore.statistics.currentLevel - 1) * 100)
        let progressInLevel = dataStore.statistics.totalXP - currentLevelXP
        return Double(max(0, min(100, progressInLevel)))
    }
    
    private var xpToNextLevel: Int {
        let target = dataStore.statistics.currentLevel * 100
        return max(0, target - dataStore.statistics.totalXP)
    }
    
    private var badgeMessage: String {
        let count = dataStore.statistics.badges.count
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
        let nextLevel = dataStore.statistics.currentLevel + 1
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
        guard let startDate = dataStore.currentUser?.startDate else { return 0 }
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
        let currentLevel = dataStore.statistics.currentLevel
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
    @EnvironmentObject var dataStore: AppDataStore
    @State private var notificationsEnabled = true
    @State private var selectedReminderFreq = ReminderFrequency.daily
    
    var body: some View {
        VStack(spacing: 14) {
            SettingsRow(
                icon: "bell.fill",
                title: "Push Notifications",
                color: Color(red: 0.45, green: 0.72, blue: 0.99)
            ) {
                Toggle("", isOn: $notificationsEnabled)
                    .labelsHidden()
                    .tint(Color(red: 0.45, green: 0.72, blue: 0.99))
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if var user = dataStore.currentUser {
                            user.profile.preferences.notificationsEnabled = newValue
                            dataStore.currentUser = user
                            dataStore.saveUserData()
                            if newValue {
                                NotificationService.shared.setupNotifications()
                            } else {
                                NotificationService.shared.cancelAllNotifications()
                            }
                        }
                    }
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
        }
        .onAppear {
            notificationsEnabled = dataStore.currentUser?.profile.preferences.notificationsEnabled ?? true
            selectedReminderFreq = dataStore.currentUser?.profile.preferences.reminderFrequency ?? .daily
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
        .softCard(accent: Color(red: 0.45, green: 0.72, blue: 0.99), cornerRadius: 28)
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
    @EnvironmentObject var dataStore: AppDataStore
    
    private var badges: [Badge] {
        // Show all badges, most recent first
        dataStore.statistics.badges.sorted(by: { $0.unlockedDate > $1.unlockedDate })
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
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var weeklyCost = ""
    @State private var selectedCurrency: String = "USD"
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showImageSourceSelection = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    private let currencies: [(code: String, symbol: String)] = [
        ("USD", "$"),
        ("EUR", "€"),
        ("GBP", "£"),
        ("BRL", "R$")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(white: 0.96)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Main Card
                        VStack(spacing: 0) {
                            // Profile Picture Section
                            VStack(spacing: 16) {
                                ZStack {
                                    if let image = profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.pink.opacity(0.35), Color.blue.opacity(0.25)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        
                                        Text(userInitials)
                                            .font(.system(size: 40, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .onTapGesture {
                                    showImageSourceSelection = true
                                }
                                
                                Button(action: {
                                    showImageSourceSelection = true
                                }) {
                                    Text("Change Photo")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 0.45, green: 0.72, blue: 0.99))
                                }
                                
                                // Name Field
                                TextField("Name", text: $name)
                                    .font(.title2.weight(.bold))
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 8)
                                
                                // Journey Start Date
                                if let startDate = dataStore.currentUser?.startDate {
                                    Text("Journey Started: \(formatDate(startDate))")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                        .padding(.top, 4)
                                }
                            }
                            .padding(.top, 32)
                            .padding(.bottom, 24)
                            
                            Divider()
                                .padding(.horizontal, 24)
                            
                            // Information Section
                            VStack(alignment: .leading, spacing: 20) {
                                HStack(spacing: 8) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                    Text("Information")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 20)
                                
                                // Weekly Cost Row
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "dollarsign.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                        Text("Amount spent on vaping per week")
                                            .font(.system(size: 15))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack(spacing: 12) {
                                        // Currency Selector
                                        Menu {
                                            ForEach(currencies, id: \.code) { currency in
                                                Button(action: {
                                                    selectedCurrency = currency.code
                                                }) {
                                                    HStack {
                                                        Text(currency.symbol)
                                                        Text(currency.code)
                                                        if selectedCurrency == currency.code {
                                                            Image(systemName: "checkmark")
                                                        }
                                                    }
                                                }
                                            }
                                        } label: {
                                            HStack(spacing: 6) {
                                                Text(getCurrencySymbol(for: selectedCurrency))
                                                    .font(.system(size: 17, weight: .medium))
                                                Image(systemName: "chevron.down")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                        }
                                        
                                        // Amount Input
                                        TextField("0.00", text: $weeklyCost)
                                            .font(.system(size: 17))
                                            .keyboardType(.decimalPad)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 8)
                                .padding(.bottom, 20)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                .dismissKeyboardOnTap()
            }
            .navigationTitle("Your Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                },
                trailing: Button("Save") {
                    saveChanges()
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(red: 0.45, green: 0.72, blue: 0.99))
            )
        }
        .onAppear {
            loadCurrentData()
        }
        .confirmationDialog("Select Photo", isPresented: $showImageSourceSelection, titleVisibility: .visible) {
            Button("Take Photo") {
                imageSourceType = .camera
                showImagePicker = true
            }
            Button("Choose from Library") {
                imageSourceType = .photoLibrary
                showImagePicker = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: imageSourceType, selectedImage: $profileImage)
        }
    }
    
    private var userInitials: String {
        let name = dataStore.currentUser?.name ?? "User"
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1)) + String(components[1].prefix(1))
        }
        return String(name.prefix(2))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    private func getCurrencySymbol(for code: String) -> String {
        return currencies.first(where: { $0.code == code })?.symbol ?? "$"
    }
    
    private func loadCurrentData() {
        name = dataStore.currentUser?.name ?? ""
        let weeklyCostValue = dataStore.currentUser?.profile.vapingHistory.dailyCost ?? 0
        weeklyCost = weeklyCostValue > 0 ? String(format: "%.2f", weeklyCostValue) : ""
        selectedCurrency = dataStore.currentUser?.profile.vapingHistory.currency ?? "USD"
        
        // Load profile picture if available
        if let imageData = dataStore.currentUser?.profile.preferences.profilePictureData,
           let image = UIImage(data: imageData) {
            profileImage = image
        }
    }
    
    private func saveChanges() {
        guard var user = dataStore.currentUser else { return }
        
        // Update name
        user.name = name.isEmpty ? "User" : name
        
        // Update weekly cost
        if let cost = Double(weeklyCost) {
            user.profile.vapingHistory.dailyCost = cost
        }
        
        // Update currency
        user.profile.vapingHistory.currency = selectedCurrency
        
        // Update profile picture
        if let image = profileImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            user.profile.preferences.profilePictureData = imageData
        }
        
        dataStore.currentUser = user
        dataStore.saveUserData()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
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
    @EnvironmentObject var dataStore: AppDataStore
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
    @EnvironmentObject var dataStore: AppDataStore
    private var name: String { dataStore.currentUser?.name ?? "Exhale" }
    
    private var days: Int {
        guard let startDate = dataStore.currentUser?.startDate else { return 0 }
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
                Text("@Exhale")
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
                    Text("exhale.app")
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
    @State private var expandedFAQ: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Help & Support")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Need assistance? We're here to help!")
                    .foregroundColor(.secondary)
                
                // FAQ section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Frequently Asked Questions")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.bottom, 4)
                    
                    FAQItem(
                        question: "How do I track my progress?",
                        answer: "Use the daily check-in feature to log your progress each day. The app tracks your streak, XP gained, and milestones automatically. You can view your progress in the Progress tab.",
                        isExpanded: expandedFAQ == "progress",
                        onTap: {
                            withAnimation {
                                expandedFAQ = expandedFAQ == "progress" ? nil : "progress"
                            }
                        }
                    )
                    
                    FAQItem(
                        question: "What happens if I miss a check-in?",
                        answer: "Missing a check-in doesn't reset your streak. Your streak is based on consecutive days without vaping, not on check-ins. However, regular check-ins help you track your progress and gain XP.",
                        isExpanded: expandedFAQ == "missed",
                        onTap: {
                            withAnimation {
                                expandedFAQ = expandedFAQ == "missed" ? nil : "missed"
                            }
                        }
                    )
                    
                    FAQItem(
                        question: "How is my streak calculated?",
                        answer: "Your current streak shows days since your start date. Your longest streak shows the longest consecutive sequence of check-ins where you stayed vape-free. Both are important metrics for your journey.",
                        isExpanded: expandedFAQ == "streak",
                        onTap: {
                            withAnimation {
                                expandedFAQ = expandedFAQ == "streak" ? nil : "streak"
                            }
                        }
                    )
                    
                    FAQItem(
                        question: "How do I earn XP?",
                        answer: "You earn 10 XP for each day you stay vape-free. You can also earn XP by completing quests. XP helps you level up and track your overall progress.",
                        isExpanded: expandedFAQ == "xp",
                        onTap: {
                            withAnimation {
                                expandedFAQ = expandedFAQ == "xp" ? nil : "xp"
                            }
                        }
                    )
                    
                    FAQItem(
                        question: "What are milestones?",
                        answer: "Milestones are significant health achievements based on days vape-free: 1 day, 3 days, 1 week, 1 month, 3 months, and 1 year. Each milestone represents important health improvements your body experiences.",
                        isExpanded: expandedFAQ == "milestones",
                        onTap: {
                            withAnimation {
                                expandedFAQ = expandedFAQ == "milestones" ? nil : "milestones"
                            }
                        }
                    )
                    
                    FAQItem(
                        question: "Can I edit a past check-in?",
                        answer: "Currently, you can only complete one check-in per day. If you need to update today's check-in, you can complete it again and it will update your existing entry for today.",
                        isExpanded: expandedFAQ == "edit",
                        onTap: {
                            withAnimation {
                                expandedFAQ = expandedFAQ == "edit" ? nil : "edit"
                            }
                        }
                    )
                    
                    FAQItem(
                        question: "What should I do if I have a craving?",
                        answer: "Use the Panic Button at the bottom of the screen for immediate support. It provides breathing exercises, reminders of why you're staying strong, and helps you get through difficult moments.",
                        isExpanded: expandedFAQ == "cravings",
                        onTap: {
                            withAnimation {
                                expandedFAQ = expandedFAQ == "cravings" ? nil : "cravings"
                            }
                        }
                    )
                    
                    FAQItem(
                        question: "How is money saved calculated?",
                        answer: "Money saved is based on the weekly cost you entered during onboarding, divided by 7 to get a daily cost, then multiplied by your days vape-free. This gives you an estimate of how much you've saved.",
                        isExpanded: expandedFAQ == "money",
                        onTap: {
                            withAnimation {
                                expandedFAQ = expandedFAQ == "money" ? nil : "money"
                            }
                        }
                    )
                    
                    FAQItem(
                        question: "What if I relapse?",
                        answer: "If you relapse, you can use the 'I relapsed' button in the Home view. This will reset your streak counter, but remember: every moment vape-free counts. Don't give up—each day is a new opportunity.",
                        isExpanded: expandedFAQ == "relapse",
                        onTap: {
                            withAnimation {
                                expandedFAQ = expandedFAQ == "relapse" ? nil : "relapse"
                            }
                        }
                    )
                    
                    FAQItem(
                        question: "Is my data private?",
                        answer: "Yes, all your data is stored locally on your device. We don't collect or share your personal information with third parties. Your progress and check-ins remain private to you.",
                        isExpanded: expandedFAQ == "privacy",
                        onTap: {
                            withAnimation {
                                expandedFAQ = expandedFAQ == "privacy" ? nil : "privacy"
                            }
                        }
                    )
                }
                .padding(.top, 8)
                
                Divider()
                    .padding(.vertical, 8)
                
                // Support contact
                VStack(alignment: .leading, spacing: 12) {
                    Text("Contact Support")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Email: f.mirandaassis@gmail.com")
                        .foregroundColor(.primary)
                        .font(.body)
                }
                .padding(.top, 4)
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .breathableBackground()
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Text(question)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(answer)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
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
        .environmentObject(AppDataStore())
}
