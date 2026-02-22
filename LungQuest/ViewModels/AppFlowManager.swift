import Foundation
import Combine
import StoreKit

// MARK: - Subscription Access State
/// Tri-state subscription status used for strict gating.
enum SubscriptionAccessState: Equatable {
    case unknown
    case subscribed
    case notSubscribed
}

// MARK: - Subscription Manager
/// Tracks subscription entitlements using StoreKit 2.
/// Publishes a tri-state access value so the UI can gate while verifying.
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var accessState: SubscriptionAccessState = .unknown
    
    var isSubscribed: Bool { accessState == .subscribed }
    
    /// Keep product IDs aligned with StoreKit config and Superwall.
    private let subscribedProductIDs: Set<String> = [
        "exhale_monthly_799",
        "exhale_annual_3999"
    ]
    
    private var updatesTask: Task<Void, Never>?
    private var fallbackTask: Task<Void, Never>?
    
    deinit {
        updatesTask?.cancel()
        fallbackTask?.cancel()
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
        // If StoreKit hangs (e.g. no active account), don't leave the app stuck in `.unknown`.
        scheduleFallbackToNotSubscribedIfStillUnknown()
        await checkEntitlements()
    }
    
    /// Checks current entitlements to see if the user is active.
    @MainActor
    private func checkEntitlements() async {
        // Verify subscription entitlements via StoreKit 2 (works for App Store + TestFlight sandbox).
        var found = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               subscribedProductIDs.contains(transaction.productID),
               transaction.revocationDate == nil {
                found = true
                break
            }
        }
        
        fallbackTask?.cancel()
        accessState = found ? .subscribed : .notSubscribed
    }
    
    /// Listens to new transactions and updates subscription state accordingly.
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                if subscribedProductIDs.contains(transaction.productID) {
                    await MainActor.run {
                        self.accessState = .subscribed
                    }
                }
                await transaction.finish()
                
                // After any transaction update, refresh entitlements to handle expiration/revocations accurately.
                Task { @MainActor in
                    await self.refreshEntitlements()
                }
            }
        }
    }
    
    @MainActor
    private func scheduleFallbackToNotSubscribedIfStillUnknown() {
        fallbackTask?.cancel()
        fallbackTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            if self?.accessState == .unknown {
                self?.accessState = .notSubscribed
            }
        }
    }
}

class AppFlowManager: ObservableObject {
    @Published var isOnboarding: Bool = true
    @Published var accessState: SubscriptionAccessState = .unknown
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    let dataStore: AppDataStore
    let subscriptionManager: SubscriptionManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataStore: AppDataStore, subscriptionManager: SubscriptionManager = .shared) {
        self.dataStore = dataStore
        self.subscriptionManager = subscriptionManager
        self.isOnboarding = dataStore.currentUser == nil

        // Start in unknown while verifying.
        self.accessState = .unknown
        self.isLoading = true

        subscriptionManager.$accessState
            .receive(on: RunLoop.main)
            .sink { [weak self] active in
                guard let self = self else { return }
                self.accessState = active
            }
            .store(in: &cancellables)

        // Always start monitoring (works in production + TestFlight sandbox + local StoreKit testing).
        subscriptionManager.start()

        // Initial verification before showing UI.
        Task { @MainActor in
            await subscriptionManager.refreshEntitlements()
            self.accessState = subscriptionManager.accessState
            self.isLoading = false
        }
        
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
    func completeOnboarding(name: String?, age: Int?, weeklyCost: Double? = nil, currency: String? = nil) {
        dataStore.completeOnboarding(name: name, age: age, weeklyCost: weeklyCost, currency: currency)
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
            "lastMilestoneNotifiedDays"
        ].forEach { defaults.removeObject(forKey: $0) }
        
        dataStore.loadUserData()
        accessState = .unknown
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
        accessState = active ? .subscribed : .notSubscribed
    }
    
    // Placeholder for Superwall delegate hook
    func handleSubscriptionStatusChange(_ status: Bool) {
        setSubscription(active: status)
    }

    var isSubscribed: Bool { accessState == .subscribed }
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
