import Foundation
import SwiftUI

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String?
    var age: Int?
    var startDate: Date
    var quitGoal: QuitGoal
    var profile: UserProfile
    
    init(id: String = UUID().uuidString, name: String = "", email: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.startDate = Date()
        self.quitGoal = QuitGoal(targetDays: 30, currentStreak: 0)
        self.profile = UserProfile()
    }
}

// MARK: - User Profile
struct UserProfile: Codable {
    var vapingHistory: VapingHistory
    var preferences: UserPreferences
    
    init() {
        self.vapingHistory = VapingHistory()
        self.preferences = UserPreferences()
    }
}

struct VapingHistory: Codable {
    var yearsVaping: Double = 0
    var dailyCost: Double = 0 // Interpreted as weekly cost in UI from now on
    var deviceType: String = ""
}

struct UserPreferences: Codable {
    var notificationsEnabled: Bool = true
    var darkMode: Bool = false
    var reminderFrequency: ReminderFrequency = .daily
}

enum ReminderFrequency: String, CaseIterable, Codable {
    case daily = "daily"
    case twice = "twice"
    case hourly = "hourly"
    case off = "off"
}

// MARK: - Quit Goal
struct QuitGoal: Codable {
    var targetDays: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastCheckIn: Date?
    
    init(targetDays: Int, currentStreak: Int = 0) {
        self.targetDays = targetDays
        self.currentStreak = currentStreak
        self.longestStreak = 0
        self.lastCheckIn = nil
    }
}

// MARK: - Progress Tracking
struct DailyProgress: Codable, Identifiable {
    let id: String
    let date: Date
    var wasVapeFree: Bool
    var cravingsLevel: Int // 1-5 scale
    var notes: String
    var mood: Mood
    var completedQuests: [String] // Quest IDs
    
    init(date: Date = Date(), wasVapeFree: Bool = true) {
        self.id = UUID().uuidString
        self.date = date
        self.wasVapeFree = wasVapeFree
        self.cravingsLevel = 1
        self.notes = ""
        self.mood = .neutral
        self.completedQuests = []
    }
}

enum Mood: String, CaseIterable, Codable {
    case terrible = "terrible"
    case bad = "bad"
    case neutral = "neutral"
    case good = "good"
    case excellent = "excellent"
    
    var emoji: String {
        switch self {
        case .terrible: return "😰"
        case .bad: return "😔"
        case .neutral: return "😐"
        case .good: return "😊"
        case .excellent: return "😄"
        }
    }
    
    var color: Color {
        switch self {
        case .terrible: return .red
        case .bad: return .orange
        case .neutral: return .gray
        case .good: return .green
        case .excellent: return .blue
        }
    }
}

// MARK: - Lung Character State
struct LungState: Codable {
    var healthLevel: Int // 0-100
    var appearance: LungAppearance
    var accessories: [String] // Unlocked accessories
    var currentSkin: String
    
    init() {
        self.healthLevel = 0
        self.appearance = LungAppearance(healthLevel: 0)
        self.accessories = []
        self.currentSkin = "default"
    }
    
    mutating func updateHealth(streak: Int) {
        // Health improves based on streak
        healthLevel = min(100, max(0, streak * 10))
        appearance = LungAppearance(healthLevel: healthLevel)
    }

    mutating func updateHealth(startDate: Date, history: VapingHistory, frequency: String?) {
        // Compute health based on elapsed time since quit and prior usage intensity
        let elapsedDays = max(0, Int(Date().timeIntervalSince(startDate) / 86_400))

        // Frequency scale derived from onboarding answers (lower is faster recovery)
        let normalizedFrequency = (frequency ?? "").lowercased()
        let frequencyScale: Double
        if normalizedFrequency.contains("occasionally") {
            frequencyScale = 0.7
        } else if normalizedFrequency.contains("few") {
            frequencyScale = 0.9
        } else if normalizedFrequency.contains("regularly") {
            frequencyScale = 1.2
        } else if normalizedFrequency.contains("almost") || normalizedFrequency.contains("constantly") {
            frequencyScale = 1.5
        } else {
            frequencyScale = 1.0
        }

        // Years vaping increases recovery horizon up to +30%
        let yearsScale = 1.0 + min(max(history.yearsVaping, 0) / 8.0, 1.0) * 0.3

        // Daily cost as proxy for consumption, up to +20%
        let costScale = 1.0 + min(max(history.dailyCost, 0) / 15.0, 1.0) * 0.2

        let intensityScale = max(0.5, frequencyScale * yearsScale * costScale)

        // Base recovery horizon (days) scaled by intensity. Minimum 21 days.
        let baseRecoveryDays: Double = 180.0
        let recoveryHorizon = max(21.0, baseRecoveryDays * intensityScale)

        // Faster early improvements with a concave easing curve (sqrt)
        let linearProgress = min(1.0, Double(elapsedDays) / recoveryHorizon)
        let easedProgress = sqrt(linearProgress)

        healthLevel = Int((easedProgress * 100.0).rounded())
        appearance = LungAppearance(healthLevel: healthLevel)
    }
}

struct LungAppearance: Codable {
    var color: String
    var opacity: Double
    var glowIntensity: Double
    var animationSpeed: Double
    
    init(healthLevel: Int) {
        // Color progression from gray to pink
        if healthLevel < 20 {
            color = "gray"
            opacity = 0.6
            glowIntensity = 0.0
        } else if healthLevel < 50 {
            color = "lightPink"
            opacity = 0.8
            glowIntensity = 0.2
        } else if healthLevel < 80 {
            color = "pink"
            opacity = 0.9
            glowIntensity = 0.5
        } else {
            color = "healthyPink"
            opacity = 1.0
            glowIntensity = 1.0
        }
        
        animationSpeed = 1.0 + (Double(healthLevel) / 100.0)
    }
}

// MARK: - Quest System
struct Quest: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var xpReward: Int
    var category: QuestCategory
    var isCompleted: Bool
    var dateAssigned: Date
    var expiresAt: Date?
    
    init(title: String, description: String, xpReward: Int = 10, category: QuestCategory = .health) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.xpReward = xpReward
        self.category = category
        self.isCompleted = false
        self.dateAssigned = Date()
        self.expiresAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())
    }
}

enum QuestCategory: String, CaseIterable, Codable {
    case health = "health"
    case mindfulness = "mindfulness"
    case social = "social"
    case education = "education"
    
    var color: Color {
        switch self {
        case .health: return .green
        case .mindfulness: return .blue
        case .social: return .purple
        case .education: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .mindfulness: return "leaf.fill"
        case .social: return "person.3.fill"
        case .education: return "book.fill"
        }
    }
}

// MARK: - Statistics
struct UserStatistics: Codable {
    var totalXP: Int
    var currentLevel: Int
    var daysVapeFree: Int
    var moneySaved: Double
    var cravingsReduced: Double
    var completedQuests: Int
    var badges: [Badge]
    
    init() {
        self.totalXP = 0
        self.currentLevel = 1
        self.daysVapeFree = 0
        self.moneySaved = 0.0
        self.cravingsReduced = 0.0
        self.completedQuests = 0
        self.badges = []
    }
    
    mutating func addXP(_ amount: Int) {
        totalXP += amount
        // Level up every 100 XP
        currentLevel = (totalXP / 100) + 1
    }
}

struct Badge: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let unlockedDate: Date
    
    init(name: String, description: String, icon: String) {
        self.id = UUID().uuidString
        self.name = name
        self.description = description
        self.icon = icon
        self.unlockedDate = Date()
    }
}

