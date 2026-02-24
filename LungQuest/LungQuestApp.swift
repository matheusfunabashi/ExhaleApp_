import SwiftUI
import SuperwallKit
import UserNotifications

/// Listens to Superwall events and updates app subscription state immediately on purchase completion.
final class SuperwallDelegateHandler: SuperwallDelegate {
    static let shared = SuperwallDelegateHandler()
    private init() {}
    
    /// Shared flag to coordinate between delegate and presentation handler.
    /// Set to true when a purchase completes, prevents premature fallback gate showing.
    static var justCompletedPurchase: Bool = false
    
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .transactionComplete:
            print("🎉 [SUPERWALL] Transaction complete - unlocking app immediately")
            // Mark purchase as just completed for handler coordination
            SuperwallDelegateHandler.justCompletedPurchase = true
            
            // Unlock immediately, then verify via StoreKit entitlements in the background.
            Task { @MainActor in
                SubscriptionManager.shared.markSubscribedOptimistically()
            }
            // CRITICAL FIX: Wait 10 seconds before checking entitlements.
            // StoreKit needs time to propagate the purchase to Transaction.currentEntitlements.
            // Checking too early will find no entitlements and revert to .notSubscribed.
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
                print("🔍 [SUPERWALL] Starting background entitlement verification (10s after purchase)")
                await SubscriptionManager.shared.refreshEntitlements()
            }
        case .paywallClose:
            print("👋 [SUPERWALL] Paywall closed")
            // CRITICAL FIX: Don't immediately refresh if a purchase just completed.
            // The purchase flow already handles verification with proper timing.
            // Only refresh if user closed without purchasing (after grace period expires).
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
                await SubscriptionManager.shared.refreshEntitlements()
            }
        default:
            break
        }
    }
}

@main
struct ExhaleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var dataStore: AppDataStore
    @StateObject private var flowManager: AppFlowManager
    
    init() {
        Superwall.configure(apiKey: "pk_632iyoKuponK4hKuK_GL9")
        Superwall.shared.delegate = SuperwallDelegateHandler.shared
        let store = AppDataStore()
        _dataStore = StateObject(wrappedValue: store)
        _flowManager = StateObject(wrappedValue: AppFlowManager(dataStore: store))
        
        // Track app launch for review prompt
        ReviewManager.shared.trackAppLaunch()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(flowManager)
                .environmentObject(dataStore)
                .preferredColorScheme(.light) // Force light mode
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        center.removeAllDeliveredNotifications()
        completionHandler()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
