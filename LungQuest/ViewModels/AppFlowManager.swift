import Foundation
import Combine
import StoreKit

// MARK: - Subscription Manager
/// Tracks subscription entitlements using StoreKit 2.
/// Keeps a simple boolean that the rest of the app can observe.
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var isSubscribed: Bool = false
    
    /// Keep product IDs aligned with StoreKit config and Superwall.
    private let subscribedProductIDs: Set<String> = [
        "exhale_monthly_799",
        "exhale_annual_3999"
    ]
    
    private var updatesTask: Task<Void, Never>?
    
    deinit {
        updatesTask?.cancel()
    }
    
    /// Start listening for entitlement and transaction updates.
    func start() {
        updatesTask = Task { [weak self] in
            await self?.refreshEntitlements()
            await self?.listenForTransactions()
        }
    }
    
    /// Manually re-check current entitlements (e.g., after a restore action).
    func refresh() {
        Task { [weak self] in
            await self?.refreshEntitlements()
        }
    }
    
    /// Checks current entitlements to see if the user is active.
    @MainActor
    private func refreshEntitlements() async {
        var found = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               subscribedProductIDs.contains(transaction.productID) {
                found = true
                break
            }
        }
        isSubscribed = found
    }
    
    /// Listens to new transactions and updates subscription state accordingly.
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                if subscribedProductIDs.contains(transaction.productID) {
                    await MainActor.run { self.isSubscribed = true }
                }
                await transaction.finish()
            }
        }
    }
}

class AppFlowManager: ObservableObject {
    @Published var isOnboarding: Bool = true
    @Published var isSubscribed: Bool = false
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    let dataStore: AppDataStore
    let subscriptionManager: SubscriptionManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataStore: AppDataStore, subscriptionManager: SubscriptionManager = .shared) {
        self.dataStore = dataStore
        self.subscriptionManager = subscriptionManager
        self.isOnboarding = dataStore.currentUser == nil
        self.isLoading = false
        
        #if DEBUG
        // Auto-bypass paywall em builds de desenvolvimento
        self.isSubscribed = true
        UserDefaults.standard.set(true, forKey: "isSubscribed")
        #else
        self.isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
        #endif
        
        subscriptionManager.$isSubscribed
            .receive(on: RunLoop.main)
            .sink { [weak self] active in
                #if !DEBUG
                self?.setSubscription(active: active)
                #endif
            }
            .store(in: &cancellables)
        
        #if !DEBUG
        subscriptionManager.start()
        #endif
        
        dataStore.objectWillChange
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.objectWillChange.send()
                if self.isOnboarding && self.dataStore.currentUser != nil {
                    self.isOnboarding = false
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Flow Transitions
    func completeOnboarding(name: String?, age: Int?) {
        dataStore.completeOnboarding(name: name, age: age)
        isOnboarding = false
    }
    
    func skipOnboarding() {
        dataStore.skipOnboarding()
        isOnboarding = false
    }
    
    func resetForNewSession() {
        let defaults = UserDefaults.standard
        [
            "currentUser",
            "dailyProgress",
            "lungState",
            "statistics",
            "questionnaire",
            "isSubscribed",
            "lastMilestoneNotifiedDays"
        ].forEach { defaults.removeObject(forKey: $0) }
        
        dataStore.loadUserData()
        isSubscribed = false
        isOnboarding = true
    }
    
    // MARK: - Subscription Helpers
    func applyReferralCode(_ code: String) -> Bool {
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return false }
        
        if normalized == "goodhealth" {
            setSubscription(active: true)
            return true
        }
        return false
    }
    
    func setSubscription(active: Bool) {
        isSubscribed = active
        UserDefaults.standard.set(active, forKey: "isSubscribed")
    }
    
    // Placeholder for Superwall delegate hook
    func handleSubscriptionStatusChange(_ status: Bool) {
        setSubscription(active: status)
    }
}

// MARK: - Questionnaire Models
struct OnboardingQuestionnaire: Codable {
    var isCompleted: Bool = false
    var reasonToQuit: String? = nil
    var yearsVaping: String? = nil
    var frequency: String? = nil
    var cravingTimes: [String] = [] // Changed to array for multiple selection
    var triedBefore: String? = nil
    var hardestPart: [String] = [] // Changed to array for multiple selection
    var supportWanted: [String] = [] // Changed to array for multiple selection
    var ageGroup: String? = nil
    var startPlan: String? = nil
    var freeText: String? = nil
}
