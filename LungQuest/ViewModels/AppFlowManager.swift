import Foundation
import Combine
import StoreKit

// MARK: - Subscription State
/// Explicit subscription state to avoid race conditions during async verification
enum SubscriptionState {
    case unknown    // Verification in progress or not yet started
    case active     // User has active subscription
    case inactive   // Verified: no active subscription
}

// MARK: - Subscription Manager
/// Tracks subscription entitlements using StoreKit 2.
/// Uses explicit state enum to prevent race conditions.
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var subscriptionState: SubscriptionState = .unknown
    
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
    /// CRITICAL: Does NOT reset to .inactive before verification completes.
    /// This prevents race condition flashing during async verification.
    @MainActor
    private func checkEntitlements() async {
        // Keep state as .unknown during verification
        // Do NOT set to .inactive here
        
        // Verify actual subscription entitlements via StoreKit 2
        var found = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               subscribedProductIDs.contains(transaction.productID) {
                found = true
                break
            }
        }
        
        // Only update state after verification completes
        subscriptionState = found ? .active : .inactive
    }
    
    /// Listens to new transactions and updates subscription state accordingly.
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                if subscribedProductIDs.contains(transaction.productID) {
                    await MainActor.run { self.subscriptionState = .active }
                }
                await transaction.finish()
            }
        }
    }
}

class AppFlowManager: ObservableObject {
    @Published var isOnboarding: Bool = true
    @Published var subscriptionState: SubscriptionState = .unknown
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
        
        // Start with subscription state as .unknown (verification in progress)
        self.subscriptionState = .unknown
        self.isLoading = true
        
        // Start subscription monitoring immediately
        subscriptionManager.start()
        
        // Observe subscription state changes from SubscriptionManager
        subscriptionManager.$subscriptionState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                self.subscriptionState = state
                // Update paywall state whenever subscription state changes
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
        // State remains .unknown during verification
        await subscriptionManager.refreshEntitlements()
        
        // State is now updated by SubscriptionManager (either .active or .inactive)
        // Update paywall state after verification completes
        updatePaywallState()
        
        // Finished loading
        isLoading = false
    }
    
    /// Updates paywall state based on onboarding and subscription status
    /// CRITICAL: Only show paywall when subscription is definitively .inactive
    /// Never show paywall during .unknown (verification in progress)
    private func updatePaywallState() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        // Only trigger paywall when we KNOW user is not subscribed
        // Never trigger during .unknown state (prevents race condition flashing)
        shouldShowPaywall = hasCompletedOnboarding && subscriptionState == .inactive
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
        subscriptionState = .unknown
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
            setSubscriptionActive()
            return true
        }
        return false
    }
    
    /// Sets subscription state to active immediately
    /// Used after successful purchase or referral code
    func setSubscriptionActive() {
        subscriptionState = .active
        updatePaywallState()
    }
    
    /// Sets subscription state to inactive
    /// Used when subscription expires or is cancelled
    func setSubscriptionInactive() {
        subscriptionState = .inactive
        updatePaywallState()
    }
    
    // Placeholder for Superwall delegate hook
    func handleSubscriptionStatusChange(_ isActive: Bool) {
        subscriptionState = isActive ? .active : .inactive
        updatePaywallState()
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
