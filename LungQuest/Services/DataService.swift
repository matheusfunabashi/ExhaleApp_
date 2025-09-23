import Foundation

class DataService: ObservableObject {
    // Firebase removed for MVP; keep simple in-memory stubs if needed later
    
    // MARK: - User Data Management
    func saveUser(_ user: User) async throws {
        // No-op in frontend-only mode
    }
    
    func loadUser(id: String) async throws -> User {
        // Return a basic guest user in frontend-only mode
        return User(id: id, name: "Guest")
    }
    
    // MARK: - Progress Data Management
    func saveProgress(_ progress: DailyProgress, userId: String) async throws {
        // No-op in frontend-only mode
    }
    
    func loadProgress(userId: String) async throws -> [DailyProgress] {
        // Return empty progress in frontend-only mode
        return []
    }
    
    // MARK: - Statistics Management
    func saveStatistics(_ stats: UserStatistics, userId: String) async throws {
        // No-op in frontend-only mode
    }
    
    func loadStatistics(userId: String) async throws -> UserStatistics {
        // Return default statistics in frontend-only mode
        return UserStatistics()
    }
}

class QuestService: ObservableObject {
    private let predefinedQuests: [Quest] = [
        Quest(title: "Stay Hydrated", 
              description: "Drink at least 8 glasses of water today", 
              xpReward: 15, 
              category: .health),
        
        Quest(title: "Take Deep Breaths", 
              description: "Practice 5 minutes of deep breathing", 
              xpReward: 10, 
              category: .mindfulness),
        
        Quest(title: "Walk It Off", 
              description: "Take a 10-minute walk when you feel cravings", 
              xpReward: 20, 
              category: .health),
        
        Quest(title: "Learn Something New", 
              description: "Read an article about quitting vaping", 
              xpReward: 15, 
              category: .education),
        
        Quest(title: "Connect with Others", 
              description: "Talk to a friend or family member about your progress", 
              xpReward: 25, 
              category: .social),
        
        Quest(title: "Mindful Moment", 
              description: "Spend 5 minutes in meditation or mindfulness", 
              xpReward: 15, 
              category: .mindfulness),
        
        Quest(title: "Healthy Snack", 
              description: "Choose a healthy snack over junk food", 
              xpReward: 10, 
              category: .health),
        
        Quest(title: "Exercise Boost", 
              description: "Do 15 minutes of any physical activity", 
              xpReward: 30, 
              category: .health),
        
        Quest(title: "Gratitude Practice", 
              description: "Write down 3 things you're grateful for", 
              xpReward: 10, 
              category: .mindfulness),
        
        Quest(title: "Clean Space", 
              description: "Organize or clean your living/work space", 
              xpReward: 15, 
              category: .health),
        
        Quest(title: "Digital Detox", 
              description: "Stay off social media for 2 hours", 
              xpReward: 20, 
              category: .mindfulness),
        
        Quest(title: "Support Someone", 
              description: "Help someone else who's trying to quit", 
              xpReward: 35, 
              category: .social)
    ]
    
    func generateDailyQuests(existing: [Quest] = []) -> [Quest] {
        let questsNeeded = 3 - existing.count
        guard questsNeeded > 0 else { return [] }
        
        let availableQuests = predefinedQuests.filter { quest in
            !existing.contains { $0.title == quest.title }
        }
        
        let shuffled = availableQuests.shuffled()
        return Array(shuffled.prefix(questsNeeded))
    }
    
    func getWeeklyChallenge() -> Quest {
        let weeklyChallenges = [
            Quest(title: "7-Day Hydration Hero", 
                  description: "Drink 8 glasses of water every day this week", 
                  xpReward: 100, 
                  category: .health),
            
            Quest(title: "Mindfulness Master", 
                  description: "Practice meditation for 10 minutes daily this week", 
                  xpReward: 150, 
                  category: .mindfulness),
            
            Quest(title: "Social Support Champion", 
                  description: "Connect with friends/family about your progress 3 times this week", 
                  xpReward: 120, 
                  category: .social),
            
            Quest(title: "Knowledge Seeker", 
                  description: "Read about health benefits of quitting vaping every day this week", 
                  xpReward: 80, 
                  category: .education)
        ]
        
        return weeklyChallenges.randomElement() ?? weeklyChallenges[0]
    }
}
