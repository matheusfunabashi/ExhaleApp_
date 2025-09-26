import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var isOnboarding: Bool = true
    @Published var lungState: LungState = LungState()
    @Published var dailyProgress: [DailyProgress] = []
    @Published var activeQuests: [Quest] = []
    @Published var statistics: UserStatistics = UserStatistics()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Onboarding questionnaire + paywall state
    @Published var questionnaire: OnboardingQuestionnaire = OnboardingQuestionnaire()
    @Published var isSubscribed: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let dataService = DataService()
    private let questService = QuestService()
    
    init() {
        loadUserData()
        generateDailyQuests()
    }
    
    // MARK: - User Authentication & Setup
    func createUser(name: String, email: String?, age: Int?, vapingHistory: VapingHistory) {
        var newUser = User(name: name, email: email)
        newUser.age = age
        newUser.profile.vapingHistory = vapingHistory
        
        currentUser = newUser
        isOnboarding = false
        
        saveUserData()
        generateDailyQuests()
    }
    
    func skipOnboarding() {
        let guestUser = User(name: "Guest")
        currentUser = guestUser
        isOnboarding = false
        generateDailyQuests()
    }
    
    // MARK: - Progress Tracking
    func checkIn(wasVapeFree: Bool, cravingsLevel: Int = 1, mood: Mood = .neutral, notes: String = "", puffInterval: PuffInterval = .none) {
        guard currentUser != nil else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if already checked in today
        if let existingIndex = dailyProgress.firstIndex(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: today) 
        }) {
            dailyProgress[existingIndex].wasVapeFree = wasVapeFree
            dailyProgress[existingIndex].cravingsLevel = cravingsLevel
            dailyProgress[existingIndex].mood = mood
            dailyProgress[existingIndex].notes = notes
            dailyProgress[existingIndex].puffInterval = puffInterval
        } else {
            let progress = DailyProgress(date: today, wasVapeFree: wasVapeFree)
            var newProgress = progress
            newProgress.cravingsLevel = cravingsLevel
            newProgress.mood = mood
            newProgress.notes = notes
            newProgress.puffInterval = puffInterval
            dailyProgress.append(newProgress)
        }
        
        updateStreak()
        updateLungHealth()
        calculateStatistics()
        saveUserData()
    }
    
    private func updateStreak() {
        guard var user = currentUser else { return }
        
        let sortedProgress = dailyProgress.sorted { $0.date > $1.date }
        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        
        for progress in sortedProgress {
            if progress.wasVapeFree {
                tempStreak += 1
                if progress.date == Calendar.current.startOfDay(for: Date()) {
                    currentStreak = tempStreak
                }
            } else {
                if tempStreak > longestStreak {
                    longestStreak = tempStreak
                }
                tempStreak = 0
            }
        }
        
        longestStreak = max(longestStreak, tempStreak)
        
        user.quitGoal.currentStreak = currentStreak
        user.quitGoal.longestStreak = longestStreak
        user.quitGoal.lastCheckIn = Date()
        currentUser = user
    }
    
    func updateLungHealth() {
        guard let user = currentUser else { return }
        // Prefer timer-based health tied to startDate and intensity inputs
        let frequencyAnswer = questionnaire.frequency
        lungState.updateHealth(startDate: user.startDate, history: user.profile.vapingHistory, frequency: frequencyAnswer)
    }
    
    private func calculateStatistics() {
        guard let user = currentUser else { return }
        
        statistics.daysVapeFree = user.quitGoal.currentStreak
        // Interpret stored cost as WEEKLY cost; convert to per-day for savings
        let perDayCost = user.profile.vapingHistory.dailyCost / 7.0
        statistics.moneySaved = Double(statistics.daysVapeFree) * perDayCost
        
        // Calculate cravings reduction (simplified)
        let recentProgress = dailyProgress.suffix(7)
        if !recentProgress.isEmpty {
            let avgCravings = recentProgress.map { Double($0.cravingsLevel) }.reduce(0, +) / Double(recentProgress.count)
            statistics.cravingsReduced = max(0, 5.0 - avgCravings) * 20 // Convert to percentage
        }
        
        checkForNewBadges()
    }
    
    private func checkForNewBadges() {
        let currentStreak = currentUser?.quitGoal.currentStreak ?? 0
        var newBadges: [Badge] = []
        
        // Check for streak badges
        if currentStreak >= 1 && !statistics.badges.contains(where: { $0.name == "First Day" }) {
            newBadges.append(Badge(name: "First Day", description: "Your first day vape-free!", icon: "star.fill"))
        }
        
        if currentStreak >= 7 && !statistics.badges.contains(where: { $0.name == "One Week Strong" }) {
            newBadges.append(Badge(name: "One Week Strong", description: "One week without vaping!", icon: "calendar"))
        }
        
        if currentStreak >= 30 && !statistics.badges.contains(where: { $0.name == "Month Champion" }) {
            newBadges.append(Badge(name: "Month Champion", description: "30 days vape-free!", icon: "crown.fill"))
        }
        
        // Check for quest completion badges
        if statistics.completedQuests >= 10 && !statistics.badges.contains(where: { $0.name == "Quest Master" }) {
            newBadges.append(Badge(name: "Quest Master", description: "Completed 10 quests!", icon: "target"))
        }
        
        statistics.badges.append(contentsOf: newBadges)
    }
    
    // MARK: - Quest System
    func completeQuest(_ questId: String) {
        guard let questIndex = activeQuests.firstIndex(where: { $0.id == questId }) else { return }
        
        activeQuests[questIndex].isCompleted = true
        let quest = activeQuests[questIndex]
        
        // Add XP
        statistics.addXP(quest.xpReward)
        statistics.completedQuests += 1
        
        // Add to today's progress
        let today = Calendar.current.startOfDay(for: Date())
        if let progressIndex = dailyProgress.firstIndex(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: today) 
        }) {
            dailyProgress[progressIndex].completedQuests.append(questId)
        }
        
        calculateStatistics()
        saveUserData()
    }
    
    private func generateDailyQuests() {
        // Remove expired quests
        activeQuests.removeAll { quest in
            if let expiresAt = quest.expiresAt {
                return Date() > expiresAt
            }
            return false
        }
        
        // Add new daily quests if needed
        let today = Calendar.current.startOfDay(for: Date())
        let todayQuests = activeQuests.filter { quest in
            Calendar.current.isDate(quest.dateAssigned, inSameDayAs: today)
        }
        
        if todayQuests.count < 3 {
            let newQuests = questService.generateDailyQuests(existing: todayQuests)
            activeQuests.append(contentsOf: newQuests)
        }
    }
    
    // MARK: - Data Persistence
    private func loadUserData() {
        isLoading = true
        
        // In a real app, this would load from Firebase
        // For now, we'll use UserDefaults for local storage
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isOnboarding = false
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
        
        isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
        
        updateLungHealth()
        isLoading = false
    }
    
    private func saveUserData() {
        // Save to UserDefaults (in real app, save to Firebase)
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
        UserDefaults.standard.set(isSubscribed, forKey: "isSubscribed")
    }
    
    // Exposed safe persistence wrapper for UI flows
    func persist() {
        saveUserData()
    }
    
    // MARK: - Utility Methods
    func getDaysVapeFree() -> Int {
        return currentUser?.quitGoal.currentStreak ?? 0
    }
    
    func getMoneySaved() -> Double {
        guard let user = currentUser else { return 0 }
        let perDayCost = user.profile.vapingHistory.dailyCost / 7.0
        return Double(getDaysVapeFree()) * perDayCost
    }
    
    func getHealthImprovements() -> String {
        let days = getDaysVapeFree()
        
        switch days {
        case 0:
            return "Start your journey today!"
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

// MARK: - Questionnaire Models
struct OnboardingQuestionnaire: Codable {
    var isCompleted: Bool = false
    var reasonToQuit: String? = nil
    var yearsVaping: String? = nil
    var frequency: String? = nil
    var cravingTimes: String? = nil
    var triedBefore: String? = nil
    var hardestPart: String? = nil
    var supportWanted: String? = nil
    var ageGroup: String? = nil
    var startPlan: String? = nil
    var freeText: String? = nil
}
