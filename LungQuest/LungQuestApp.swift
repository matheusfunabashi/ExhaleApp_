import SwiftUI
import SuperwallKit
import UserNotifications

@main
struct ExhaleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var dataStore: AppDataStore
    @StateObject private var flowManager: AppFlowManager
    
    init() {
        // Configure Superwall
        Superwall.configure(apiKey: "pk_632iyoKuponK4hKuK_GL9")
        
        let store = AppDataStore()
        _dataStore = StateObject(wrappedValue: store)
        
        let flow = AppFlowManager(dataStore: store)
        _flowManager = StateObject(wrappedValue: flow)
        
        // Set Superwall delegate to track subscription status
        Superwall.shared.delegate = SuperwallDelegateHandler.shared
        SuperwallDelegateHandler.shared.flowManager = flow
        
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

/// Handles Superwall events and updates AppFlowManager
/// CRITICAL: Immediately sets subscription to .active on purchase completion
/// This prevents race condition where background refresh might temporarily show paywall
final class SuperwallDelegateHandler: SuperwallDelegate {
    static let shared = SuperwallDelegateHandler()
    weak var flowManager: AppFlowManager?
    
    private init() {}
    
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .transactionStart(let product):
            print("💳 Superwall: Transaction started for product: \(product.productIdentifier)")
            
        case .transactionComplete:
            print("✅ Superwall: Transaction completed successfully")
            // User completed a purchase - IMMEDIATELY set to active
            // Do NOT wait for background entitlement refresh
            flowManager?.setSubscriptionActive()
            flowManager?.dismissPaywall()
            
            // Also refresh entitlements in background to verify
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                await flowManager?.subscriptionManager.refreshEntitlements()
            }
            
        case .transactionFail(let error):
            print("❌ Superwall: Transaction failed - \(error)")
            
        case .transactionAbandon:
            print("ℹ️ Superwall: User abandoned transaction")
            
        case .paywallOpen:
            print("🔵 Superwall: Paywall opened")
            
        case .paywallClose:
            print("🔵 Superwall: Paywall closed")
            // User closed paywall - refresh to get latest state
            // State remains .unknown during refresh, preventing flashing
            Task { @MainActor in
                await flowManager?.subscriptionManager.refreshEntitlements()
            }
            
        default:
            break
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
