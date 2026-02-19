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
        // Verify actual subscription entitlements via StoreKit 2
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
    @Published var shouldShowPaywall: Bool = false
    @Published var errorMessage: String?
    #if DEBUG
    @Published var isDevModeOnboarding: Bool = false
    #endif
    
    let dataStore: AppDataStore
    let subscriptionManager: SubscriptionManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataStore: AppDataStore, subscriptionManager: SubscriptionManager = .shared) {
        self.dataStore = dataStore
        self.subscriptionManager = subscriptionManager
        
        // Determine onboarding state from persistent flag
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.isOnboarding = !hasCompletedOnboarding
        
        // Start with subscription verification
        self.isLoading = true
        
        // Start subscription monitoring immediately
        subscriptionManager.start()
        
        // Observe subscription changes from SubscriptionManager
        subscriptionManager.$isSubscribed
            .receive(on: RunLoop.main)
            .sink { [weak self] active in
                guard let self = self else { return }
                self.isSubscribed = active
                // Update paywall state
                self.updatePaywallState()
            }
            .store(in: &cancellables)
        
        // Observe dataStore changes
        dataStore.objectWillChange
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        // Verify subscription status before showing UI
        Task { @MainActor in
            await self.verifySubscriptionInBackground()
        }
    }
    
    @MainActor
    private func verifySubscriptionInBackground() async {
        // Verify subscription via StoreKit
        await subscriptionManager.refreshEntitlements()
        
        // Update state from subscription manager
        isSubscribed = subscriptionManager.isSubscribed
        
        // Determine if paywall should be shown
        updatePaywallState()
        
        // Finished loading
        isLoading = false
    }
    
    /// Updates paywall state based on onboarding and subscription status
    private func updatePaywallState() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        shouldShowPaywall = hasCompletedOnboarding && !isSubscribed
    }
    
    // MARK: - Flow Transitions
    func completeOnboarding(name: String?, age: Int?, weeklyCost: Double? = nil, currency: String? = nil) {
        dataStore.completeOnboarding(name: name, age: age, weeklyCost: weeklyCost, currency: currency)
        
        // Mark onboarding as completed persistently
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        isOnboarding = false
        
        // Update paywall state
        updatePaywallState()
    }
    
    func skipOnboarding() {
        dataStore.skipOnboarding()
        isOnboarding = false
    }
    
    func resetForNewSession(devMode: Bool = false) {
        #if DEBUG
        isDevModeOnboarding = devMode
        #endif
        let defaults = UserDefaults.standard
        [
            "currentUser",
            "dailyProgress",
            "lungState",
            "statistics",
            "questionnaire",
            "hasCompletedOnboarding",
            "lastMilestoneNotifiedDays"
        ].forEach { defaults.removeObject(forKey: $0) }
        
        dataStore.loadUserData()
        isSubscribed = false
        isOnboarding = true
        shouldShowPaywall = false
    }
    
    #if DEBUG
    func exitDevModeOnboarding() {
        isDevModeOnboarding = false
        isOnboarding = false
    }
    #endif
    
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
        updatePaywallState()
    }
    
    // Placeholder for Superwall delegate hook
    func handleSubscriptionStatusChange(_ status: Bool) {
        setSubscription(active: status)
    }
    
    /// Dismiss paywall after successful subscription
    func dismissPaywall() {
        shouldShowPaywall = false
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
