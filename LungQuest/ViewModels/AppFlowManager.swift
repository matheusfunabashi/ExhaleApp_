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
        Task { @MainActor [weak self] in
            await self?.refreshEntitlements()
        }
    }
    
    /// Public method to refresh entitlements (for AppFlowManager access)
    @MainActor
    func refreshEntitlements() async {
        await checkEntitlements()
    }
    
    /// Checks current entitlements to see if the user is active.
    @MainActor
    private func checkEntitlements() async {
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
    @Published var isCheckingSubscription: Bool = false
    @Published var errorMessage: String?
    
    let dataStore: AppDataStore
    let subscriptionManager: SubscriptionManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataStore: AppDataStore, subscriptionManager: SubscriptionManager = .shared) {
        self.dataStore = dataStore
        self.subscriptionManager = subscriptionManager
        self.isOnboarding = dataStore.currentUser == nil
        
        #if DEBUG
        // Auto-bypass paywall em builds de desenvolvimento
        self.isSubscribed = true
        self.isLoading = false
        self.isCheckingSubscription = false
        UserDefaults.standard.set(true, forKey: "isSubscribed")
        #else
        // Load subscription state from UserDefaults first (trust it initially)
        let savedSubscriptionState = UserDefaults.standard.bool(forKey: "isSubscribed")
        self.isSubscribed = savedSubscriptionState
        
        // If we have a saved subscription state, show app immediately and verify in background
        // Otherwise, check subscription before showing app
        if savedSubscriptionState {
            self.isLoading = false
            self.isCheckingSubscription = true
            // Verify subscription in background without blocking
            Task { @MainActor in
                await self.verifySubscriptionInBackground()
            }
        } else {
            self.isLoading = true
            self.isCheckingSubscription = true
            // Check subscription before showing app
            Task { @MainActor in
                await self.verifySubscriptionOnStartup()
            }
        }
        #endif
        
        subscriptionManager.$isSubscribed
            .receive(on: RunLoop.main)
            .sink { [weak self] active in
                #if !DEBUG
                guard let self = self else { return }
                // Only update if we're not in the middle of initial check
                if !self.isCheckingSubscription {
                    self.setSubscription(active: active)
                }
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
    
    #if !DEBUG
    @MainActor
    private func verifySubscriptionOnStartup() async {
        // First, try to load from SubscriptionManager
        await subscriptionManager.refreshEntitlements()
        
        // Check if subscription manager found a subscription
        if subscriptionManager.isSubscribed {
            setSubscription(active: true)
        } else {
            // If no subscription found, check UserDefaults as fallback
            let savedState = UserDefaults.standard.bool(forKey: "isSubscribed")
            if savedState {
                // UserDefaults says subscribed but SubscriptionManager doesn't
                // This could be a referral code or manual unlock
                // Trust UserDefaults for now
                setSubscription(active: true)
            } else {
                setSubscription(active: false)
            }
        }
        
        isCheckingSubscription = false
        isLoading = false
    }
    
    @MainActor
    private func verifySubscriptionInBackground() async {
        // Verify subscription without blocking UI
        await subscriptionManager.refreshEntitlements()
        
        // Update if SubscriptionManager found a different state
        if subscriptionManager.isSubscribed != isSubscribed {
            setSubscription(active: subscriptionManager.isSubscribed)
        }
        
        isCheckingSubscription = false
    }
    #endif
    
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
