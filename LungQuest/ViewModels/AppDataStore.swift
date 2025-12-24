import Foundation
import SwiftUI

class AppDataStore: ObservableObject {
    @Published var currentUser: User?
    @Published var lungState: LungState = LungState()
    @Published var dailyProgress: [DailyProgress] = []
    @Published var activeQuests: [Quest] = []
    @Published var statistics: UserStatistics = UserStatistics()
    @Published var questionnaire: OnboardingQuestionnaire = OnboardingQuestionnaire()
    
    private let dataService = DataService()
    private let questService = QuestService()
    
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
        currentUser = newUser
        saveUserData()
        generateDailyQuests()
    }
    
    func completeOnboarding(name: String?, age: Int?) {
        let userName = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Guest"
        var user = User(name: userName.isEmpty ? "Guest" : userName)
        if let age = age {
            user.age = age
        }
        currentUser = user
        saveUserData()
        generateDailyQuests()
    }
    
    func skipOnboarding() {
        currentUser = User(name: "Guest")
        saveUserData()
        generateDailyQuests()
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
                if Calendar.current.isDateInToday(progress.date) {
                    currentStreak = tempStreak
                }
            } else {
                longestStreak = max(longestStreak, tempStreak)
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
        
        checkForNewBadges()
    }
    
    private func checkForNewBadges() {
        let currentStreak = currentUser?.quitGoal.currentStreak ?? 0
        var newBadges: [Badge] = []
        
        if currentStreak >= 1 && !statistics.badges.contains(where: { $0.name == "First Day" }) {
            newBadges.append(Badge(name: "First Day", description: "Your first day vape-free!", icon: "star.fill"))
        }
        if currentStreak >= 7 && !statistics.badges.contains(where: { $0.name == "One Week Strong" }) {
            newBadges.append(Badge(name: "One Week Strong", description: "One week without vaping!", icon: "calendar"))
        }
        if currentStreak >= 30 && !statistics.badges.contains(where: { $0.name == "Month Champion" }) {
            newBadges.append(Badge(name: "Month Champion", description: "30 days vape-free!", icon: "crown.fill"))
        }
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
        statistics.addXP(quest.xpReward)
        statistics.completedQuests += 1
        
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
           let user = try? JSONDecoder().decode(User.self, from: userData) {
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
        
        updateLungHealth()
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
    }
    
    func persist() {
        saveUserData()
    }
    
    // MARK: - Utility
    func getDaysVapeFree() -> Int {
        return currentUser?.quitGoal.currentStreak ?? 0
    }
    
    func daysSinceQuitStartDate() -> Int {
        guard let startDate = currentUser?.startDate else { return 0 }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: start, to: today)
        return max(0, components.day ?? 0)
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

