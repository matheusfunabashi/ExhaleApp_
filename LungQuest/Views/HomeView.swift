import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showCheckIn = false
    @State private var showCelebration = false
    @State private var showCalendar = false
    @State private var showMoney = false
    @State private var showHealth = false
    @State private var showSlipConfirmation = false
    #if DEBUG
    @State private var showDevMenu = false
    #endif
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // App Title with Fire Streak
                    HStack {
                        Text("Exhale")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                        FireStreakIcon()
                    }

                    // Integrated Hero Section
                    HeroSection(
                        onMilestone: {
                            showCelebration = true
                        }
                    )
                    #if DEBUG
                    .contentShape(Rectangle())
                    .onTapGesture(count: 5) {
                        showDevMenu = true
                    }
                    #endif
                    
                    // Quick stats
                    StatsSection(
                        onDaysTapped: { showCalendar = true },
                        onMoneyTapped: { showMoney = true },
                        onHealthTapped: { showHealth = true }
                    )
                    
                    // Daily check-in
                    SlipButton(resetAction: { showSlipConfirmation = true })
                    
                    CheckInSectionWrapper(showCheckIn: $showCheckIn)
                    
                    // Learn preview
                    LearningPreviewSection()
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.pink.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .sheet(isPresented: $showCheckIn) {
            CheckInModalView()
        }
        .sheet(isPresented: $showCalendar) {
            NavigationView {
                MonthlyCalendarView()
                    .navigationTitle("This Month")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showCalendar = false }
                        }
                    }
            }
            .environmentObject(appState)
        }
        .sheet(isPresented: $showMoney) {
            NavigationView {
                MoneySavedView()
                    .navigationTitle("Money Saved")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showMoney = false }
                        }
                    }
            }
            .environmentObject(appState)
        }
        .sheet(isPresented: $showHealth) {
            NavigationView {
                HealthImprovementsView()
                    .navigationTitle("Health Improvements")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showHealth = false }
                        }
                    }
            }
            .environmentObject(appState)
        }
        #if DEBUG
        .sheet(isPresented: $showDevMenu) {
            DevMenuView()
                .environmentObject(appState)
        }
        #endif
        .overlay(
            CelebrationView(isShowing: $showCelebration)
        )
        .alert("Reset Your Streak?", isPresented: $showSlipConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, I vaped", role: .destructive) {
                resetTimerForSlip()
            }
        } message: {
            Text("This will reset your vape-free streak to 0. Are you sure you want to continue?")
        }
        .onAppear {}
    }
    
    private func checkForNewStreak() { }

    private func resetTimerForSlip() {
        // Record slip for today and reset timer to now
        appState.checkIn(wasVapeFree: false)
        if var user = appState.currentUser {
            user.startDate = Date()
            appState.currentUser = user
        }
        UserDefaults.standard.set(0, forKey: "lastMilestoneNotifiedDays")
        appState.updateLungHealth()
        appState.persist()
    }
}

struct StatsSection: View {
    @EnvironmentObject var appState: AppState
    var onDaysTapped: (() -> Void)? = nil
    var onMoneyTapped: (() -> Void)? = nil
    var onHealthTapped: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 15) {
            StatsCard(
                title: "Days Free",
                value: "\(appState.getDaysVapeFree())",
                icon: "calendar",
                color: .green,
                onTap: { onDaysTapped?() }
            )
            
            StatsCard(
                title: "Money Saved",
                value: "$\(Int(appState.getMoneySaved()))",
                icon: "dollarsign.circle.fill",
                color: .blue,
                onTap: { onMoneyTapped?() }
            )
            
            StatsCard(
                title: "Upgrades",
                value: "Health",
                icon: "heart.text.square.fill",
                color: .orange,
                onTap: { onHealthTapped?() }
            )
        }
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var onTap: (() -> Void)? = nil
    var valueFont: Font = .headline
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(valueFont)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            if !title.isEmpty {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(radius: 5)
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }
}

struct CheckInSection: View {
    @EnvironmentObject var appState: AppState
    @Binding var showCheckIn: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Daily Check-in")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if hasCheckedInToday {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            if hasCheckedInToday {
                HStack {
                    Image(systemName: "party.popper.fill")
                        .foregroundColor(.pink)
                    Text("Great job today! You've checked in.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
            } else {
                Button(action: {
                    showCheckIn = true
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                        Text("Check In Now")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.pink)
                    )
                    .foregroundColor(.white)
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
    
    private var hasCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return appState.dailyProgress.contains { progress in
            Calendar.current.isDate(progress.date, inSameDayAs: today)
        }
    }
}


struct LearningPreviewSection: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Learn")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { NotificationCenter.default.post(name: Notification.Name("SwitchToLearnTab"), object: nil) }) {
                    Text("Explore All")
                        .font(.subheadline)
                        .foregroundColor(.pink)
                }
            }
            
            VStack(spacing: 10) {
                LearningRow(icon: "heart.text.square.fill", title: "Benefits of quitting", subtitle: "Your body heals from day one")
                LearningRow(icon: "lungs.fill", title: "What vaping does", subtitle: "Understand short and long-term risks")
                LearningRow(icon: "lightbulb.fill", title: "Tips to quit", subtitle: "Craving hacks and routines that work")
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

struct LearningRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.pink)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Calendar Modal
struct MonthlyCalendarView: View {
    @EnvironmentObject var appState: AppState
    private let calendar = Calendar.current
    private var monthDays: [Date] {
        let today = Date()
        let comps = calendar.dateComponents([.year, .month], from: today)
        let startOfMonth = calendar.date(from: comps) ?? today
        // calendar.range returns Range<Int>; provide a matching fallback 1..<31
        let range: Range<Int> = calendar.range(of: .day, in: .month, for: startOfMonth) ?? (1..<31)
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    private func isVapeFree(_ date: Date) -> Bool {
        appState.dailyProgress.contains { p in
            Calendar.current.isDate(p.date, inSameDayAs: date) && p.wasVapeFree
        }
    }
    private func dayNumber(_ date: Date) -> String {
        String(calendar.component(.day, from: date))
    }
    var body: some View {
        VStack(spacing: 12) {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(["S","M","T","W","T","F","S"], id: \.self) { w in
                    Text(w).font(.caption2).foregroundColor(.secondary)
                }
                ForEach(monthDays, id: \.self) { date in
                    let success = isVapeFree(date)
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(success ? Color.green.opacity(0.2) : Color.clear)
                        Text(dayNumber(date))
                            .foregroundColor(success ? .green : .primary)
                            .fontWeight(success ? .semibold : .regular)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 36)
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.9)))
            .shadow(radius: 4)
            Spacer(minLength: 0)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.pink.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Money Saved View
struct MoneySavedView: View {
    @EnvironmentObject var appState: AppState
    private var perDay: Double {
        let weekly = appState.currentUser?.profile.vapingHistory.dailyCost ?? 0
        return weekly / 7.0
    }
    private var projections: [(title: String, days: Int)] {
        [("1 Month", 30), ("6 Months", 182), ("1 Year", 365)]
    }
    var body: some View {
        VStack(spacing: 16) {
            // Simple bar chart
            let maxVal = max(1.0, projections.map { Double($0.days) * perDay }.max() ?? 1)
            VStack(alignment: .leading, spacing: 12) {
                ForEach(projections, id: \.title) { item in
                    let val = Double(item.days) * perDay
                    HStack {
                        Text(item.title).frame(width: 90, alignment: .leading)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.gray.opacity(0.15))
                                Capsule().fill(Color.blue.opacity(0.6))
                                    .frame(width: max(8, geo.size.width * CGFloat(val / maxVal)))
                            }
                        }
                        .frame(height: 16)
                        Text("$\(Int(val))").frame(width: 70, alignment: .trailing)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.9)))
            .shadow(radius: 4)

            VStack(alignment: .leading, spacing: 6) {
                Text("Your weekly cost: $\(Int((appState.currentUser?.profile.vapingHistory.dailyCost ?? 0)))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text("Estimated savings assume consistent avoidance of vaping.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.pink.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Health Improvements Detail
struct HealthImprovementsView: View {
    @EnvironmentObject var appState: AppState
    private var days: Int {
        appState.getDaysVapeFree()
    }
    private var timeline: [(when: String, description: String, minDays: Int)] {
        [
            ("20 minutes", "Heart rate and blood pressure drop", 0),
            ("24 hours", "Carbon monoxide levels normalize", 1),
            ("72 hours", "Nicotine is out of your system", 3),
            ("1 week", "Taste and smell improve", 7),
            ("1 month", "Lung function increases up to 30%", 30),
            ("3 months", "Circulation and breathing improve", 90),
            ("1 year", "Risk of heart disease is cut in half", 365)
        ]
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("You’ve been vape‑free for \(days) day\(days == 1 ? "" : "s").")
                    .font(.headline)
                Text("Here’s what your body is likely experiencing based on time since quitting:")
                    .foregroundColor(.secondary)
                VStack(spacing: 12) {
                    ForEach(timeline, id: \.minDays) { item in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: days >= item.minDays ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(days >= item.minDays ? .green : .gray)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.when).font(.subheadline).fontWeight(.semibold)
                                Text(item.description).font(.footnote).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.9)))
                    }
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.pink.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct CelebrationView: View {
    @Binding var isShowing: Bool
    @State private var animationPhase = 0
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.4)
                    .onTapGesture {
                        isShowing = false
                    }
                
                VStack(spacing: 20) {
                    Text("🎉")
                        .font(.system(size: 60))
                        .scaleEffect(animationPhase == 0 ? 0.5 : 1.2)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationPhase)
                    
                    Text("Milestone Reached!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    Text("Keep up the amazing work!")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button("Continue") {
                        isShowing = false
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 20)
                )
                .scaleEffect(animationPhase == 0 ? 0.8 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationPhase)
            }
            .onAppear {
                animationPhase = 1
            }
        }
    }
}

// Helper struct to fix the CheckInSection binding issue
struct CheckInSectionWrapper: View {
    @Binding var showCheckIn: Bool
    
    var body: some View {
        CheckInSection(showCheckIn: $showCheckIn)
    }
}

// MARK: - New Hero Views

private struct SlipButton: View {
    let resetAction: () -> Void
    var body: some View {
        Button(action: resetAction) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                Text("I vaped")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.red))
            .foregroundColor(.white)
        }
        .accessibilityLabel("I vaped. Reset timer")
    }
}


struct BreathingLungCharacter: View {
    let healthLevel: Int
    @State private var breathe: Bool = false
    @State private var bob: Bool = false
    
    private var bucketedLevel: Int {
        let clamped = max(0, min(100, healthLevel))
        let buckets: [Int] = [0, 25, 50, 75, 100]
        if let nearest = buckets.min(by: { abs($0 - clamped) < abs($1 - clamped) }) { return nearest }
        return 0
    }
    
    private var assetName: String { "LungBuddy_\(bucketedLevel)" }
    private var hasAsset: Bool { UIImage(named: assetName) != nil }
    
    var body: some View {
        Group {
            if hasAsset {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
            } else {
                LungCharacter(healthLevel: healthLevel, isAnimating: true)
            }
        }
            .frame(width: 220 * 1.4, height: 176 * 1.4)
            .scaleEffect(breathe ? 1.02 : 0.98)
            .offset(y: bob ? -4 : 4)
            .animation(breathingAnimation, value: breathe)
            .animation(bobbingAnimation, value: bob)
            .accessibilityHidden(true)
            .onAppear { breathe = true; bob = true }
    }
    
    private var animationDuration: Double {
        let base = 2.2
        let factor = 1.2 - (Double(healthLevel) / 100.0)
        return max(0.9, base * factor)
    }
    
    private var breathingAnimation: Animation {
        .easeInOut(duration: animationDuration).repeatForever(autoreverses: true)
    }
    
    private var bobbingAnimation: Animation {
        .easeInOut(duration: max(0.9, 2.0 * (1.2 - (Double(healthLevel) / 100.0)))).repeatForever(autoreverses: true)
    }
}

struct HealthIndicator: View {
    let healthLevel: Int
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Lung Health")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(healthLevel)%")
                    .font(.subheadline).bold()
                    .monospacedDigit()
                    .accessibilityLabel("Lung health \(healthLevel) percent")
            }
            SwiftUI.ProgressView(value: Double(healthLevel) / 100.0)
                .tint(.pink)
                .accessibilityHidden(true)
        }
    }
}

struct SupportMessage: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .accessibilityLabel("Support message: \(text)")
    }
}

#if DEBUG
// MARK: - Developer Menu (DEBUG only)
struct DevMenuView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var showIntake: Bool = false
    @State private var showDevCheckIn: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Timer")) {
                    Button("Reset timer to now") { setStartDate(to: Date()) }
                    Button("Advance +1 hour") { shiftStartDate(hours: 1) }
                    Button("Advance +1 day") { shiftStartDate(days: 1) }
                    Button("Advance +7 days") { shiftStartDate(days: 7) }
                }
                
                Section(header: Text("Questionnaire")) {
                    Button("Open Onboarding Questionnaire") { showIntake = true }
                }

                Section(header: Text("Check-in")) {
                    Button("Re-do today's check-in") { showDevCheckIn = true }
                }
            }
            .navigationTitle("Developer Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
        .sheet(isPresented: $showIntake) {
            IntakeView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showDevCheckIn) {
            CheckInModalView()
                .environmentObject(appState)
        }
    }
    
    private func setStartDate(to date: Date) {
        guard var user = appState.currentUser else { return }
        user.startDate = date
        appState.currentUser = user
        appState.persist()
        appState.updateLungHealth()
    }
    
    private func shiftStartDate(days: Int = 0, hours: Int = 0, minutes: Int = 0) {
        let seconds = (days * 86_400) + (hours * 3_600) + (minutes * 60)
        guard let current = appState.currentUser?.startDate else { return }
        let newDate = current.addingTimeInterval(TimeInterval(-seconds))
        setStartDate(to: newDate)
    }
}
#endif

// MARK: - New Integrated Hero Section
struct HeroSection: View {
    @EnvironmentObject var appState: AppState
    let onMilestone: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Top: Weekday streak row
            WeekdayStreakRow()
            
            // Center: LungBuddy
            LungBuddyCenter()
            
            // Bottom: Hero timer
            HeroTimerView(
                startDate: appState.currentUser?.startDate ?? Date(),
                onMilestone: onMilestone
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
    }
}

struct WeekdayStreakRow: View {
    @EnvironmentObject var appState: AppState
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
    
    private func hasCheckIn(on date: Date) -> Bool {
        appState.dailyProgress.contains { Calendar.current.isDate($0.date, inSameDayAs: date) && $0.wasVapeFree }
    }
    
    private func shortWeekday(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = "EEE"
        return df.string(from: date).uppercased()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(weekDays, id: \.self) { date in
                VStack(spacing: 8) {
                    Text(shortWeekday(date))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                            .frame(width: 32, height: 32)
                        
                        if hasCheckIn(on: date) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                                .transition(.scale)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }
}

struct LungBuddyCenter: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 16) {
            BreathingLungCharacter(healthLevel: appState.lungState.healthLevel)
                .scaleEffect(1.2) // Make LungBuddy bigger
            
            HealthIndicator(healthLevel: appState.lungState.healthLevel)
        }
        .padding(.vertical, 20)
    }
}

struct HeroTimerView: View {
    @EnvironmentObject var appState: AppState
    let startDate: Date
    var onMilestone: (() -> Void)? = nil
    
    @State private var now: Date = Date()
    @AppStorage("lastMilestoneNotifiedDays") private var lastMilestoneNotifiedDays: Int = 0
    
    private var timer: Timer.TimerPublisher {
        Timer.publish(every: 1, on: .main, in: .common)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Timer label
            Text("You have been vape-free for")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Main timer display
            Text(formattedTime)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .bold()
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundColor(.primary)
            
            // Live seconds chip
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .scaleEffect(now.timeIntervalSince1970.truncatingRemainder(dividingBy: 2) < 1 ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: now)
                
                Text("\(seconds)s")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .onReceive(timer.autoconnect()) { newValue in
            now = newValue
            appState.updateLungHealth()
            handleMilestonesIfNeeded()
        }
        .onAppear {
            appState.updateLungHealth()
        }
    }
    
    private var elapsed: TimeInterval { now.timeIntervalSince(startDate) }
    
    private var formattedTime: String {
        let totalSeconds = max(0, Int(elapsed))
        let days = totalSeconds / 86_400
        let hours = (totalSeconds % 86_400) / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        
        return "\(days)d \(hours)hrs \(minutes)mins"
    }
    
    private var seconds: Int {
        max(0, Int(elapsed) % 60)
    }
    
    private func handleMilestonesIfNeeded() {
        let days = max(0, Int(elapsed) / 86_400)
        guard let nextMilestone = nextMilestoneDay(after: lastMilestoneNotifiedDays) else { return }
        if days >= nextMilestone {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            lastMilestoneNotifiedDays = nextMilestone
            onMilestone?()
        }
    }
    
    private func nextMilestoneDay(after day: Int) -> Int? {
        let milestones = [1, 3, 7, 14, 30, 60, 90, 120, 180, 365]
        return milestones.first { $0 > day }
    }
}

struct FireStreakIcon: View {
    @EnvironmentObject var appState: AppState
    
    private var consecutiveCheckInDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var consecutiveDays = 0
        
        // Get all check-in dates sorted by date (most recent first)
        let checkInDates = appState.dailyProgress
            .filter { $0.wasVapeFree }
            .map { calendar.startOfDay(for: $0.date) }
            .sorted { $0 > $1 }
        
        // Count consecutive days from today backwards
        var currentDate = today
        for checkInDate in checkInDates {
            if calendar.isDate(checkInDate, inSameDayAs: currentDate) {
                consecutiveDays += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return consecutiveDays
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundColor(.orange)
            
            Text("\(consecutiveCheckInDays)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
