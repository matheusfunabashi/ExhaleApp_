import Foundation

extension UserProfile {
    var effectiveStartDate: Date? {
        if let relapseDate = lastRelapseDate {
            return Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: relapseDate))
        }
        return quitStartDate
    }
    
    var streakDays: Int {
        guard let effectiveStartDate else { return 0 }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: effectiveStartDate)
        let now = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: start, to: now).day ?? 0
        return max(days, 0)
    }
}

final class ProfileStore: ObservableObject {
    @Published var profile: UserProfile {
        didSet {
            save()
        }
    }
    
    private let storageKey = "com.exhale.profile"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? decoder.decode(UserProfile.self, from: data) {
            profile = decoded
        } else {
            // New users start with 0 days - use current date as quit start date
            profile = UserProfile(id: UUID(), quitStartDate: Date(), lastRelapseDate: nil)
            save()
        }
    }
    
    private func save() {
        guard let data = try? encoder.encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    func resetProfile(with profile: UserProfile) {
        self.profile = profile
    }
}

