import Foundation
import SwiftUI

class AppDataStore: ObservableObject {
    @Published var currentUser: User?
    @Published var lungState: LungState = LungState()
    @Published var dailyProgress: [DailyProgress] = []
    @Published var activeQuests: [Quest] = []
    @Published var statistics: UserStatistics = UserStatistics()
    @Published var questionnaire: OnboardingQuestionnaire = OnboardingQuestionnaire()
    @Published var readLessons: [String] = [] // Lesson titles that have been read
    
    private let dataService = DataService()
    private let questService = QuestService()
    
    /// Currency symbol for the current user (from profile.vapingHistory.currency).
    var currencySymbol: String {
        let code = currentUser?.profile.vapingHistory.currency ?? "USD"
        switch code {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "BRL": return "R$"
        default: return "$"
        }
    }
    
    init(autoLoad: Bool = true) {
        if autoLoad {
            loadUserData()
            generateDailyQuests()
        }
    }
    
    // MARK: - User Setup
    func createUser(name: String, email: String?, age: Int?, vapingHistory: VapingHistory) {
        var newUser = User(name: name, email: email)
        newUser.age = age
        newUser.profile.vapingHistory = vapingHistory
        newUser.profile.quitStartDate = newUser.profile.quitStartDate ?? newUser.startDate
        currentUser = newUser
        saveUserData()
        generateDailyQuests()
    }
    
    func completeOnboarding(name: String?, age: Int?, weeklyCost: Double? = nil, currency: String? = nil) {
        let userName = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Guest"
        var user = User(name: userName.isEmpty ? "Guest" : userName)
        if let age = age {
            user.age = age
        }
        if let weeklyCost = weeklyCost {
            user.profile.vapingHistory.dailyCost = weeklyCost
        }
        if let currency = currency {
            // Map currency symbols to currency codes
            let currencyCode: String
            switch currency {
            case "$": currencyCode = "USD"
            case "€": currencyCode = "EUR"
            case "£": currencyCode = "GBP"
            case "R$": currencyCode = "BRL"
            default: currencyCode = "USD"
            }
            user.profile.vapingHistory.currency = currencyCode
        }
        user.profile.quitStartDate = user.profile.quitStartDate ?? user.startDate
        currentUser = user
        saveUserData()
        generateDailyQuests()
        setupNotificationsIfEnabled()
    }
    
    func skipOnboarding() {
        currentUser = User(name: "Guest")
        saveUserData()
        generateDailyQuests()
        setupNotificationsIfEnabled()
    }
    
    // MARK: - Progress Tracking
    func checkIn(wasVapeFree: Bool, cravingsLevel: Int = 1, mood: Mood = .neutral, notes: String = "", puffInterval: PuffInterval = .none) {
        guard currentUser != nil else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        if let existingIndex = dailyProgress.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            dailyProgress[existingIndex].wasVapeFree = wasVapeFree
            dailyProgress[existingIndex].cravingsLevel = cravingsLevel
            dailyProgress[existingIndex].mood = mood
            dailyProgress[existingIndex].notes = notes
            dailyProgress[existingIndex].puffInterval = puffInterval
        } else {
            var progress = DailyProgress(date: today, wasVapeFree: wasVapeFree)
            progress.cravingsLevel = cravingsLevel
            progress.mood = mood
            progress.notes = notes
            progress.puffInterval = puffInterval
            dailyProgress.append(progress)
        }

        if !wasVapeFree {
            resetQuitTimerForSlip()
        }
        
        updateStreak()
        updateLungHealth()
        calculateStatistics()
        saveUserData()
        
        // Cancel check-in reminder if notifications are enabled (user completed it)
        if currentUser?.profile.preferences.notificationsEnabled == true {
            // The notification will still fire today, but user completed it
            // We could cancel it, but since it's daily repeating, it's fine to let it fire
        }
        
        // Request review if conditions are met (onboarding completed is checked by currentUser != nil)
        ReviewManager.shared.requestReviewIfNeeded(
            onboardingCompleted: currentUser != nil,
            hasOpenedProgressView: false,
            hasCompletedCheckIn: true
        )
    }

    /// Call when user taps "I relapsed". Resets streak timer and marks today as not vape-free without doing a full check-in (no review prompt, etc.).
    func recordRelapse() {
        guard currentUser != nil else { return }
        let today = Calendar.current.startOfDay(for: Date())
        if let existingIndex = dailyProgress.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyProgress[existingIndex].wasVapeFree = false
        } else {
            var progress = DailyProgress(date: today, wasVapeFree: false)
            dailyProgress.append(progress)
        }
        resetQuitTimerForSlip()
        updateStreak()
        updateLungHealth()
        calculateStatistics()
        saveUserData()
    }

    private func resetQuitTimerForSlip() {
        guard var user = currentUser else { return }
        user.startDate = Date()
        // Do not change user.profile.quitStartDate — Money Saved uses it so it does not reset on relapse
        currentUser = user
        UserDefaults.standard.set(0, forKey: "lastMilestoneNotifiedDays")
    }
    
    private func updateStreak() {
        guard var user = currentUser else { return }
        let sortedProgress = dailyProgress.sorted { $0.date > $1.date }
        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        let today = Calendar.current.startOfDay(for: Date())
        var foundToday = false
        
        // Calculate streak from most recent progress
        for progress in sortedProgress {
            if progress.wasVapeFree {
                tempStreak += 1
                if Calendar.current.isDateInToday(progress.date) {
                    currentStreak = tempStreak
                    foundToday = true
                }
            } else {
                if !foundToday && currentStreak == 0 {
                    // If we haven't found today yet, this could be the current streak
                    currentStreak = tempStreak
                }
                longestStreak = max(longestStreak, tempStreak)
                tempStreak = 0
            }
        }
        
        // If we didn't find today but have consecutive days, use the temp streak
        if !foundToday && currentStreak == 0 && tempStreak > 0 {
            // Check if the most recent progress is recent (within last few days)
            if let mostRecent = sortedProgress.first,
               Calendar.current.dateComponents([.day], from: mostRecent.date, to: today).day ?? 999 <= 1 {
                currentStreak = tempStreak
            }
        }
        
        longestStreak = max(longestStreak, tempStreak, longestStreak)
        user.quitGoal.currentStreak = currentStreak
        user.quitGoal.longestStreak = longestStreak
        if let lastProgress = sortedProgress.first {
            user.quitGoal.lastCheckIn = lastProgress.date
        }
        currentUser = user
    }
    
    func updateLungHealth() {
        guard let user = currentUser else { return }
        lungState.updateHealth(
            startDate: user.startDate,
            history: user.profile.vapingHistory,
            frequency: questionnaire.frequency
        )
    }
    
    private func calculateStatistics() {
        guard let user = currentUser else { return }
        statistics.daysVapeFree = user.quitGoal.currentStreak
        let perDayCost = user.profile.vapingHistory.dailyCost / 7.0
        statistics.moneySaved = Double(statistics.daysVapeFree) * perDayCost
        
        let recentProgress = dailyProgress.suffix(7)
        if !recentProgress.isEmpty {
            let avgCravings = recentProgress.map { Double($0.cravingsLevel) }.reduce(0, +) / Double(recentProgress.count)
            statistics.cravingsReduced = max(0, 5.0 - avgCravings) * 20
        }
        
        // Calculate daily XP based on days vape-free
        let daysSinceStart = daysSinceQuitStartDate()
        let dailyXP = calculateDailyXP(days: daysSinceStart)
        
        // Update total XP: never decrease (e.g. on relapse); preserve XP from quests and past days
        let oldLevel = statistics.currentLevel
        statistics.totalXP = max(statistics.totalXP, dailyXP)
        statistics.currentLevel = (statistics.totalXP / 100) + 1
        // If level increased, trigger notification
        if statistics.currentLevel > oldLevel {
            objectWillChange.send()
        }
        
        // Update completed quests to show milestones achieved
        statistics.completedQuests = countCompletedMilestones(days: daysSinceStart)
        
        checkForNewBadges()
    }
    
    private func calculateDailyXP(days: Int) -> Int {
        // Award 10 XP per day vape-free
        return days * 10
    }
    
    private func countCompletedMilestones(days: Int) -> Int {
        let milestones = [1, 3, 7, 30, 90, 365]
        return milestones.filter { days >= $0 }.count
    }
    
    private func checkForNewBadges() {
        // Use days since start date for time-based badges (more reliable than streak)
        let daysSinceStart = daysSinceQuitStartDate()
        var newBadges: [Badge] = []
        
        // Check all eligible badges and add any that are missing
        if daysSinceStart >= 1 && !statistics.badges.contains(where: { $0.name == "First Day" }) {
            newBadges.append(Badge(name: "First Day", description: "Your first day vape-free!", icon: "star.fill"))
        }
        if daysSinceStart >= 7 && !statistics.badges.contains(where: { $0.name == "One Week Strong" }) {
            newBadges.append(Badge(name: "One Week Strong", description: "One week without vaping!", icon: "calendar"))
        }
        if daysSinceStart >= 30 && !statistics.badges.contains(where: { $0.name == "Month Champion" }) {
            newBadges.append(Badge(name: "Month Champion", description: "30 days vape-free!", icon: "crown.fill"))
        }
        if statistics.completedQuests >= 3 && !statistics.badges.contains(where: { $0.name == "Milestone Master" }) {
            newBadges.append(Badge(name: "Milestone Master", description: "Achieved 3 milestones!", icon: "target"))
        }
        
        // Add all new badges at once
        if !newBadges.isEmpty {
            statistics.badges.append(contentsOf: newBadges)
            objectWillChange.send()
        }
    }
    
    // MARK: - Quest System
    func completeQuest(_ questId: String) {
        guard let questIndex = activeQuests.firstIndex(where: { $0.id == questId }) else { return }
        activeQuests[questIndex].isCompleted = true
        let quest = activeQuests[questIndex]
        // Add XP from quest (this will be preserved when calculateStatistics runs)
        statistics.addXP(quest.xpReward)
        // Note: completedQuests is now calculated from milestones, so we don't increment it here
        
        let today = Calendar.current.startOfDay(for: Date())
        if let progressIndex = dailyProgress.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyProgress[progressIndex].completedQuests.append(questId)
        }
        
        calculateStatistics()
        saveUserData()
    }
    
    private func generateDailyQuests() {
        activeQuests.removeAll { quest in
            if let expiresAt = quest.expiresAt {
                return Date() > expiresAt
            }
            return false
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let todayQuests = activeQuests.filter { Calendar.current.isDate($0.dateAssigned, inSameDayAs: today) }
        if todayQuests.count < 3 {
            let newQuests = questService.generateDailyQuests(existing: todayQuests)
            activeQuests.append(contentsOf: newQuests)
        }
    }
    
    // MARK: - Persistence
    func loadUserData() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           var user = try? JSONDecoder().decode(User.self, from: userData) {
            user.profile.quitStartDate = user.profile.quitStartDate ?? user.startDate
            currentUser = user
        }
        
        if let progressData = UserDefaults.standard.data(forKey: "dailyProgress"),
           let progress = try? JSONDecoder().decode([DailyProgress].self, from: progressData) {
            dailyProgress = progress
        }
        
        if let lungData = UserDefaults.standard.data(forKey: "lungState"),
           let lung = try? JSONDecoder().decode(LungState.self, from: lungData) {
            lungState = lung
        }
        
        if let statsData = UserDefaults.standard.data(forKey: "statistics"),
           let stats = try? JSONDecoder().decode(UserStatistics.self, from: statsData) {
            statistics = stats
        }
        
        if let qData = UserDefaults.standard.data(forKey: "questionnaire"),
           let q = try? JSONDecoder().decode(OnboardingQuestionnaire.self, from: qData) {
            questionnaire = q
        }
        
        if let readLessonsData = UserDefaults.standard.array(forKey: "readLessons") as? [String] {
            readLessons = readLessonsData
        }
        
        // Update streak based on loaded progress
        updateStreak()
        updateLungHealth()
        
        // Calculate statistics and check for badges when app loads
        if currentUser != nil {
            calculateStatistics()
            setupNotificationsIfEnabled()
        }
    }
    
    func saveUserData() {
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
        
        if let progressData = try? JSONEncoder().encode(dailyProgress) {
            UserDefaults.standard.set(progressData, forKey: "dailyProgress")
        }
        
        if let lungData = try? JSONEncoder().encode(lungState) {
            UserDefaults.standard.set(lungData, forKey: "lungState")
        }
        
        if let statsData = try? JSONEncoder().encode(statistics) {
            UserDefaults.standard.set(statsData, forKey: "statistics")
        }
        
        if let qData = try? JSONEncoder().encode(questionnaire) {
            UserDefaults.standard.set(qData, forKey: "questionnaire")
        }
        
        UserDefaults.standard.set(readLessons, forKey: "readLessons")
    }
    
    func persist() {
        saveUserData()
    }
    
    // MARK: - Reading Tracking
    func markLessonAsRead(_ lessonTitle: String) {
        if !readLessons.contains(lessonTitle) {
            readLessons.append(lessonTitle)
            saveUserData()
            objectWillChange.send() // Explicitly notify views of the change
            
            // If this is today's reading, we could cancel the notification
            // But since it's daily repeating, it will check again tomorrow
        }
    }
    
    func isLessonRead(_ lessonTitle: String) -> Bool {
        return readLessons.contains(lessonTitle)
    }
    
    /// Returns whether the given lesson (today's reading) has been marked as read.
    /// The caller must pass the same title used for the daily reading (e.g. from HomeView).
    func isReadingOfTheDayCompleted(todayTitle: String) -> Bool {
        return isLessonRead(todayTitle)
    }
    
    // MARK: - Daily Reading (one random reading per calendar day)
    private let dailyReadingLastDateKey = "dailyReadingLastDate"
    private let dailyReadingTitleKey = "dailyReadingTitle"
    
    /// Returns the title of today's reading. If current calendar day != last stored date, picks a new random title from the pool and persists it with today's date. Otherwise returns the stored title. Single source of truth for the "Complete today's reading" button.
    func getDailyReadingTitle(fromTitles titles: [String]) -> String? {
        guard !titles.isEmpty else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let storedTimeInterval = UserDefaults.standard.object(forKey: dailyReadingLastDateKey) as? TimeInterval
        let storedTitle = UserDefaults.standard.string(forKey: dailyReadingTitleKey)
        let isSameDay: Bool = {
            guard let ti = storedTimeInterval else { return false }
            let storedDay = Date(timeIntervalSince1970: ti)
            return calendar.isDate(storedDay, inSameDayAs: today)
        }()
        if isSameDay, let title = storedTitle, titles.contains(title) {
            return title
        }
        // New day or invalid stored title: pick random and persist
        let chosen = titles.randomElement() ?? titles[0]
        UserDefaults.standard.set(today.timeIntervalSince1970, forKey: dailyReadingLastDateKey)
        UserDefaults.standard.set(chosen, forKey: dailyReadingTitleKey)
        objectWillChange.send()
        return chosen
    }
    
    // MARK: - Notification Management
    func setupNotificationsIfEnabled() {
        guard let user = currentUser else { return }
        
        // Only setup notifications if user is subscribed
        let isSubscribed = SubscriptionManager.shared.isSubscribed
        
        if user.profile.preferences.notificationsEnabled && isSubscribed {
            NotificationService.shared.setupNotifications(isSubscribed: isSubscribed)
        } else {
            NotificationService.shared.cancelAllNotifications()
        }
    }
    
    func hasCheckedInToday() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyProgress.contains { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    // MARK: - Utility
    func getDaysVapeFree() -> Int {
        return currentUser?.quitGoal.currentStreak ?? 0
    }
    
    /// Same source of truth as the main "X days vape-free" counter (DaysCounterView). Elapsed seconds since startDate / 86400. Resets when user relapses (startDate is reset). Use this for Lung Boost / Health Improvements so they stay in sync with the main counter.
    func daysVapeFreeForMainCounter() -> Int {
        guard let startDate = currentUser?.startDate else { return 0 }
        return max(0, Int(Date().timeIntervalSince(startDate)) / 86_400)
    }
    
    func daysSinceQuitStartDate() -> Int {
        guard let startDate = currentUser?.startDate else { return 0 }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: start, to: today)
        return max(0, components.day ?? 0)
    }
    
    /// Days since the user's first quit date (never reset on relapse). Used for Money Saved and similar.
    func daysSinceFirstQuitDate() -> Int {
        guard let user = currentUser else { return 0 }
        let firstDate = user.profile.quitStartDate ?? user.startDate
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: firstDate)
        let today = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: start, to: today)
        return max(0, components.day ?? 0)
    }
    
    func getMoneySaved() -> Double {
        guard let user = currentUser else { return 0 }
        let perDayCost = user.profile.vapingHistory.dailyCost / 7.0
        return Double(getDaysVapeFree()) * perDayCost
    }
    
    /// Money saved since first quit date (never resets on relapse). Same value used on Home, Progress, and Profile.
    func moneySavedFromFirstQuit() -> Double {
        guard let user = currentUser else { return 0 }
        let weeklyCost = user.profile.vapingHistory.dailyCost > 0 ? user.profile.vapingHistory.dailyCost : 20.0
        let dailyCost = weeklyCost / 7.0
        return Double(daysSinceFirstQuitDate()) * dailyCost
    }
    
    /// Formatted money saved string: symbol + integer, no space (e.g. "R$11" or "$11").
    func formattedMoneySaved() -> String {
        "\(currencySymbol)\(Int(moneySavedFromFirstQuit()))"
    }
    
    func getHealthImprovements() -> String {
        let days = getDaysVapeFree()
        switch days {
        case 0:
            return "Your body is ready to begin healing"
        case 1...3:
            return "Your body is beginning to heal"
        case 4...7:
            return "Lung function starting to improve"
        case 8...30:
            return "Significant lung healing in progress"
        case 31...90:
            return "Major lung function improvements"
        default:
            return "Lungs functioning at optimal health!"
        }
    }
}

