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
    @State private var showHeroGlow = false
    @State private var encouragementTick: Int = 0
    @State private var encouragementTimer: Timer?
    #if DEBUG
    @State private var showDevMenu = false
    #endif
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    // App Title with Fire Streak
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Exhale")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(red: 0.16, green: 0.36, blue: 0.87), Color(red: 0.45, green: 0.72, blue: 0.99)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            if !greetingName.isEmpty {
                                Text("Keep breathing easy, \(greetingName).")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        FireStreakIcon()
                    }
                    .padding(.horizontal)

                    // New Hero Layout - No white box
                    VStack(spacing: 22) {
                        WeekdayStreakRow()
                        
                        LungBuddyCenter()
                            .padding(.top, 8)
                        
                        Text(lungMoodCopy)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0.16, green: 0.36, blue: 0.87))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                        
                        VStack(spacing: 10) {
                            Text("You’ve been vape-free for")
                                .font(.system(.footnote, design: .rounded).weight(.medium))
                                .foregroundColor(.secondary)
                            
                            DaysCounterView()
                                .environmentObject(appState)
                            
                            NewHeroTimerView(
                                onMilestone: {
                                    showCelebration = true
                                    triggerHeroGlow()
                                }
                            )
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.92), Color.white.opacity(0.75)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                            .blendMode(.overlay)
                                    )
                                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text(healthInsight)
                                .font(.footnote)
                                .foregroundColor(.primary)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            EncouragementBubble(message: encouragementMessage)
                                .id(encouragementTick)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                        
                        VStack(spacing: 6) {
                            CheckInButton(showCheckIn: $showCheckIn)
                            Text(hasCheckedInToday ? "Thanks for checking in today" : "Tap to share how you’re feeling")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .softCard(accent: heroAccentColor, cornerRadius: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(heroAccentColor.opacity(showHeroGlow ? 0.45 : 0.0), lineWidth: 6)
                            .blur(radius: showHeroGlow ? 1 : 10)
                            .animation(.easeInOut(duration: 1.1), value: showHeroGlow)
                    )
                    .padding(.horizontal)
                    #if DEBUG
                    .contentShape(Rectangle())
                    .onTapGesture(count: 5) {
                        showDevMenu = true
                    }
                    #endif
                    
                    HomeSection(
                        title: "Your journey",
                        subtitle: "Keep tabs on streaks, savings, and how your lungs are healing."
                    ) {
                        StatsSection(
                            onDaysTapped: { showCalendar = true },
                            onMoneyTapped: { showMoney = true },
                            onHealthTapped: { showHealth = true }
                        )
                    }
                    .padding(.horizontal)
                    
                    HomeSection(
                        title: "Daily actions",
                        subtitle: "Check in or note a slip with kindness—every tap moves you forward."
                    ) {
                        ActionsCard(showCheckIn: $showCheckIn) {
                            showSlipConfirmation = true
                        }
                    }
                    .padding(.horizontal)
                    
                    HomeSection(
                        title: "Learn & reflect",
                        subtitle: "Short reads to reinforce your progress and calm cravings."
                    ) {
                        LearningPreviewSection()
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .breathableBackground()
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
        .alert("Reset Your Progress?", isPresented: $showSlipConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Begin Again", role: .destructive) {
                resetTimerForSlip()
            }
        } message: {
            Text("Slips happen. Logging it now helps you keep moving forward with compassion.")
        }
        .onAppear { startEncouragementRotation() }
        .onDisappear { stopEncouragementRotation() }
    }
    
    private func checkForNewStreak() { }

    private func triggerHeroGlow() {
        showHeroGlow = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeOut(duration: 0.8)) {
                showHeroGlow = false
            }
        }
    }

    private func startEncouragementRotation() {
        encouragementTimer?.invalidate()
        encouragementTimer = Timer.scheduledTimer(withTimeInterval: 18, repeats: true) { _ in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).speed(0.9)) {
                encouragementTick += 1
            }
        }
    }

    private func stopEncouragementRotation() {
        encouragementTimer?.invalidate()
        encouragementTimer = nil
    }

    private var greetingName: String {
        let fullName = appState.currentUser?.name ?? ""
        return fullName.split(separator: " ").first.map(String.init) ?? ""
    }

    private var hasCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return appState.dailyProgress.contains { progress in
            Calendar.current.isDate(progress.date, inSameDayAs: today)
        }
    }
    
    private var healthInsight: String {
        let days = appState.getDaysVapeFree()
        switch days {
        case ..<1:
            return "Every single pass on a vape gives your lungs more room to recover."
        case 1...2:
            return "Within 24 hours your oxygen levels begin to rebound—keep noticing those deeper breaths."
        case 3...6:
            return "Nicotine is clearing out and your oxygen flow is improving today."
        case 7...29:
            return "One calm week in: your lungs are expanding easier and circulation is smoothing out."
        case 30...89:
            return "Each smoke-free day is restoring stamina and brighter energy for your routines."
        default:
            return "Your body keeps regenerating—oxygen delivery and lung capacity rise with every streak."
        }
    }

    private var lungMoodCopy: String {
        let health = appState.lungState.healthLevel
        switch health {
        case 0..<25:
            return "Your lungs are ready for tiny breaths of reset—every calm moment helps."
        case 25..<50:
            return "Fresh air is settling in; your lungs are starting to feel lighter."
        case 50..<75:
            return "Your lung buddy is smiling wider with every check-in today."
        default:
            return "Your lungs feel bright and grateful—keep soaking in that clarity."
        }
    }

    private var encouragementMessage: String {
        let messages: [String] = [
            "Small breaths of courage lead to giant steps of freedom.",
            "You’re teaching your body a calmer rhythm—keep listening to it.",
            "Your future self is already grateful for today’s choice.",
            "Pauses like this build resilience. Celebrate this inhale.",
            "You are worthy of gentle progress, not perfection.",
            "Strength grows in the quiet moments you say ‘not today.’"
        ]
        let calendar = Calendar.current
        let daySeed = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = abs(daySeed + encouragementTick) % messages.count
        return messages[index]
    }

    private var heroAccentColor: Color {
        let health = appState.lungState.healthLevel
        switch health {
        case 0..<25:
            return Color(red: 0.84, green: 0.41, blue: 0.46)
        case 25..<50:
            return Color(red: 0.67, green: 0.52, blue: 0.93)
        case 50..<75:
            return Color(red: 0.38, green: 0.63, blue: 0.97)
        default:
            return Color(red: 0.26, green: 0.67, blue: 0.61)
        }
    }

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
        HStack(spacing: 16) {
            StatsCard(
                title: "Days Free",
                value: "\(appState.getDaysVapeFree())",
                icon: "calendar",
                color: .orange,
                onTap: { onDaysTapped?() }
            )
            
            StatsCard(
                title: "Money Saved",
                value: formattedMoneySaved,
                icon: "dollarsign.circle.fill",
                color: .blue,
                onTap: { onMoneyTapped?() }
            )
            
            StatsCard(
                title: "Lung Boost",
                value: "\(appState.lungState.healthLevel)%",
                icon: "heart.text.square.fill",
                color: .green,
                onTap: { onHealthTapped?() }
            )
        }
    }
    
    private var formattedMoneySaved: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: appState.getMoneySaved())) ?? "$0"
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
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.35), color.opacity(0.12)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.25), lineWidth: 1)
                    )
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color.opacity(0.9))
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                if !title.isEmpty {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .softCard(accent: color, cornerRadius: 26)
        .frame(maxWidth: .infinity)
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
        VStack(spacing: 14) {
            LearningRow(icon: "heart.text.square.fill", title: "Benefits of quitting", subtitle: "Your body heals from day one")
            LearningRow(icon: "lungs.fill", title: "What vaping does", subtitle: "Understand short and long-term risks")
            LearningRow(icon: "lightbulb.fill", title: "Tips to quit", subtitle: "Craving hacks and routines that work")
            Button(action: { NotificationCenter.default.post(name: Notification.Name("SwitchToLearnTab"), object: nil) }) {
                HStack(spacing: 6) {
                    Text("Explore the full library")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.bold))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Capsule()
                        .fill(Color(red: 0.85, green: 0.32, blue: 0.57).opacity(0.14))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(Color(red: 0.85, green: 0.32, blue: 0.57))
        }
    }
}

struct LearningRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0.85, green: 0.32, blue: 0.57).opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(red: 0.85, green: 0.32, blue: 0.57).opacity(0.25), lineWidth: 1)
                    )
                Image(systemName: icon)
                    .foregroundColor(Color(red: 0.85, green: 0.32, blue: 0.57))
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Circle()
                .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.secondary)
                )
        }
        .padding(.vertical, 6)
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
        .breathableBackground()
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
        .breathableBackground()
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
        .breathableBackground()
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
                
                ConfettiView()
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                
                VStack(spacing: 20) {
                    Text("🌟")
                        .font(.system(size: 64))
                        .scaleEffect(animationPhase == 0 ? 0.6 : 1.15)
                        .animation(.spring(response: 0.6, dampingFraction: 0.75), value: animationPhase)
                    
                    VStack(spacing: 8) {
                        Text("Milestone unlocked")
                            .font(.title2.weight(.bold))
                            .foregroundColor(Color(red: 0.85, green: 0.32, blue: 0.57))
                        Text("Each milestone unlocks brighter breathing—take a moment to feel that win.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    
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

private struct EncouragementBubble: View {
    let message: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .font(.caption.weight(.semibold))
                .foregroundColor(Color(red: 0.85, green: 0.32, blue: 0.57))
                .padding(6)
                .background(
                    Circle()
                        .fill(Color(red: 0.85, green: 0.32, blue: 0.57).opacity(0.12))
                )
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
        )
    }
}

private struct HomeSection<Content: View>: View {
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

private struct ActionsCard: View {
    @EnvironmentObject var appState: AppState
    @Binding var showCheckIn: Bool
    let slipTapped: () -> Void
    
    private var hasCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return appState.dailyProgress.contains { progress in
            Calendar.current.isDate(progress.date, inSameDayAs: today)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(hasCheckedInToday ? "Thanks for reflecting today." : "A quick daily check-in keeps your momentum steady.")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text("Log how you feel, then note slips with compassion when they happen.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if hasCheckedInToday {
                HStack(spacing: 10) {
                    Image(systemName: "party.popper.fill")
                        .foregroundColor(.green)
                    Text("Already logged today—beautiful work!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.green.opacity(0.12))
                )
            } else {
                CheckInButton(showCheckIn: $showCheckIn)
                    .frame(maxWidth: .infinity)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Slip moments happen—logging them helps you restart with kindness.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button(action: slipTapped) {
                    HStack {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.headline)
                        Text("Had a slip")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(red: 0.94, green: 0.33, blue: 0.33).opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color(red: 0.94, green: 0.33, blue: 0.33).opacity(0.22), lineWidth: 1)
                            )
                    )
                }
                .foregroundColor(Color(red: 0.74, green: 0.13, blue: 0.26))
            }
        }
    }
}

private struct ConfettiView: View {
    private let particles: [ConfettiParticle] = {
        let palette: [Color] = [
            Color(red: 0.85, green: 0.32, blue: 0.57),
            Color(red: 0.38, green: 0.63, blue: 0.97),
            Color(red: 0.26, green: 0.67, blue: 0.61),
            Color.orange,
            Color.white
        ]
        let symbols = ["●", "✦", "▴", "✱"]
        return (0..<24).map { index in
            ConfettiParticle(
                relativeX: Double.random(in: 0...1),
                color: palette[index % palette.count].opacity(0.9),
                rotation: Double.random(in: -160...160),
                size: CGFloat.random(in: 10...17),
                symbol: symbols.randomElement() ?? "●",
                delay: Double.random(in: 0...0.6)
            )
        }
    }()
    
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { particle in
                Text(particle.symbol)
                    .font(.system(size: particle.size))
                    .foregroundColor(particle.color)
                    .position(
                        x: CGFloat(particle.relativeX) * geo.size.width,
                        y: animate ? geo.size.height + 60 : -60
                    )
                    .rotationEffect(.degrees(animate ? particle.rotation : 0))
                    .opacity(animate ? 0.0 : 1.0)
                    .animation(
                        Animation.easeOut(duration: 2.6)
                            .delay(particle.delay),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let relativeX: Double
    let color: Color
    let rotation: Double
    let size: CGFloat
    let symbol: String
    let delay: Double
}

private struct SlipButton: View {
    let resetAction: () -> Void
    var body: some View {
        Button(action: resetAction) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .foregroundColor(.white)
                Text("Had a slip")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.94, green: 0.33, blue: 0.33), Color(red: 0.74, green: 0.13, blue: 0.26)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(red: 0.74, green: 0.13, blue: 0.26).opacity(0.25), radius: 16, x: 0, y: 10)
            )
            .foregroundColor(.white)
        }
        .accessibilityLabel("Record a slip and restart kindly")
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
        NotificationCenter.default.post(name: NSNotification.Name("UserStartDateChanged"), object: nil)
    }
    
    private func shiftStartDate(days: Int = 0, hours: Int = 0, minutes: Int = 0) {
        let seconds = (days * 86_400) + (hours * 3_600) + (minutes * 60)
        guard let current = appState.currentUser?.startDate else { return }
        let newDate = current.addingTimeInterval(TimeInterval(-seconds))
        setStartDate(to: newDate)
    }
}
#endif

// MARK: - New Check-in Button (Circular with pen icon)
struct CheckInButton: View {
    @EnvironmentObject var appState: AppState
    @Binding var showCheckIn: Bool
    
    @State private var isPulsing: Bool = false
    
    private var hasCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return appState.dailyProgress.contains { progress in
            Calendar.current.isDate(progress.date, inSameDayAs: today)
        }
    }
    
    private var accentGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color(red: 0.45, green: 0.72, blue: 0.99), Color(red: 0.16, green: 0.36, blue: 0.87)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var completedGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.green.opacity(0.85), Color.green.opacity(0.65)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        Button(action: {
            if !hasCheckedInToday {
                showCheckIn = true
            }
        }) {
            ZStack {
                Circle()
                    .fill(hasCheckedInToday ? completedGradient : accentGradient)
                    .frame(width: 64, height: 64)
                    .shadow(color: (hasCheckedInToday ? Color.green : Color(red: 0.16, green: 0.36, blue: 0.87)).opacity(0.34), radius: 18, x: 0, y: 10)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(hasCheckedInToday ? 0.28 : 0.45), lineWidth: 3)
                    )
                    .scaleEffect(hasCheckedInToday ? 1.0 : (isPulsing ? 1.05 : 0.97))
                    .animation(
                        hasCheckedInToday ? .default : .easeInOut(duration: 2.2).repeatForever(autoreverses: true),
                        value: isPulsing
                    )
                
                Circle()
                    .stroke((hasCheckedInToday ? Color.green : Color(red: 0.16, green: 0.36, blue: 0.87)).opacity(0.18), lineWidth: 1.5)
                    .frame(width: 74, height: 74)
                    .opacity(hasCheckedInToday ? 0.4 : 0.7)
                
                Image(systemName: hasCheckedInToday ? "checkmark" : "pencil")
                    .foregroundColor(.white)
                    .font(.title3.weight(.bold))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear { isPulsing = true }
        .accessibilityLabel(hasCheckedInToday ? "You’re checked in for today" : "Open daily check-in")
    }
}

// MARK: - Days Counter View
struct DaysCounterView: View {
    @EnvironmentObject var appState: AppState
    @State private var now: Date = Date()
    
    private var timer: Timer.TimerPublisher {
        Timer.publish(every: 1, on: .main, in: .common)
    }
    
    private var startDate: Date {
        appState.currentUser?.startDate ?? Date()
    }
    
    private var days: Int {
        let elapsed = now.timeIntervalSince(startDate)
        return max(0, Int(elapsed) / 86_400)
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(days)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            Text("Days")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        }
        .onReceive(timer.autoconnect()) { newValue in
            now = newValue
        }
        .onAppear {
            now = Date()
        }
        .onChange(of: appState.currentUser?.startDate) { _ in
            now = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserStartDateChanged"))) { _ in
            now = Date()
        }
    }
}

// MARK: - New Hero Timer View (days, hours, minutes, seconds format)
struct NewHeroTimerView: View {
    @EnvironmentObject var appState: AppState
    var onMilestone: (() -> Void)? = nil
    
    @State private var now: Date = Date()
    @AppStorage("lastMilestoneNotifiedDays") private var lastMilestoneNotifiedDays: Int = 0
    
    private var timer: Timer.TimerPublisher {
        Timer.publish(every: 1, on: .main, in: .common)
    }
    
    private var startDate: Date {
        appState.currentUser?.startDate ?? Date()
    }
    
    var body: some View {
        let elapsed = now.timeIntervalSince(startDate)
        let totalSeconds = max(0, Int(elapsed))
        let days = totalSeconds / 86_400
        let hours = (totalSeconds % 86_400) / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60
        
        HStack(spacing: 16) {
            timeMetric(value: hours, label: "hrs")
            timeMetric(value: minutes, label: "mins")
            timeMetric(value: seconds, label: "secs")
        }
        .onReceive(timer.autoconnect()) { newValue in
            now = newValue
            appState.updateLungHealth()
            handleMilestonesIfNeeded()
        }
        .onAppear {
            now = Date()
            appState.updateLungHealth()
        }
        .onChange(of: appState.currentUser?.startDate) { _ in
            now = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserStartDateChanged"))) { _ in
            now = Date()
        }
    }
    
    private func handleMilestonesIfNeeded() {
        let elapsed = now.timeIntervalSince(startDate)
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
    
    private func timeMetric(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.primary)
            Text(label.uppercased())
                .font(.caption2)
                .fontWeight(.medium)
                .kerning(0.8)
                .foregroundColor(.secondary)
        }
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
    }
}

struct LungBuddyCenter: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        BreathingLungCharacter(healthLevel: appState.lungState.healthLevel)
            .scaleEffect(1.2) // Make LungBuddy bigger
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
